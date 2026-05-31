import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tbank/src/core/constants/constants.dart';
import 'package:tbank/src/core/widgets/custom_text_field.dart';
import 'package:tbank/src/core/widgets/gradient_button.dart';
import 'package:tbank/src/core/widgets/in_app_notification.dart';
import 'package:tbank/src/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:tbank/src/features/transfer/presentation/controllers/transfer_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionApprovalScreen extends StatefulWidget {
  final Uri uri;

  const TransactionApprovalScreen({super.key, required this.uri});

  @override
  State<TransactionApprovalScreen> createState() =>
      _TransactionApprovalScreenState();
}

class _TransactionApprovalScreenState extends State<TransactionApprovalScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigning = false;

  void _onReject() async {
    final callback = widget.uri.queryParameters['callback'];
    if (callback != null && callback.isNotEmpty) {
      final callbackUri = Uri.parse(
        '$callback?status=failed&reason=user_rejected',
      );
      try {
        if (await canLaunchUrl(callbackUri)) {
          await launchUrl(callbackUri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('Failed to launch callback: $e');
      }
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _onApprove() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      InAppNotification.show(
        context,
        'Please enter your password to sign the transaction',
        isError: true,
      );
      return;
    }

    final amount = widget.uri.queryParameters['amount'] ?? '0';
    final recipient = widget.uri.queryParameters['recipient'] ?? '';
    final currency = widget.uri.queryParameters['currency'] ?? 'ToroG';
    final callback = widget.uri.queryParameters['callback'];

    if (recipient.isEmpty) {
      InAppNotification.show(
        context,
        'Invalid transaction payload: recipient missing',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSigning = true;
    });

    try {
      final onboarding = context.read<OnboardingController>();
      final transferController = context.read<TransferController>();

      final activeWallet = onboarding.activeWallet;
      if (activeWallet == null) {
        throw Exception('No active wallet found');
      }

      final txHash = await transferController.executeTransfer(
        fromAddress: activeWallet.address,
        toAddress: recipient,
        amount: amount,
        currency: currency,
        password: password,
      );

      if (txHash != null) {
        if (callback != null && callback.isNotEmpty) {
          final callbackUri = Uri.parse(
            '$callback?status=success&txHash=$txHash',
          );
          try {
            if (await canLaunchUrl(callbackUri)) {
              await launchUrl(
                callbackUri,
                mode: LaunchMode.externalApplication,
              );
            }
          } catch (e) {
            debugPrint('Failed to launch callback: $e');
          }
        }
        if (mounted) {
          InAppNotification.show(
            context,
            'Transaction signed and broadcasted successfully!',
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted && transferController.errorMessage != null) {
          InAppNotification.show(
            context,
            transferController.errorMessage!,
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        InAppNotification.show(
          context,
          'Failed to sign transaction: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = widget.uri.queryParameters['amount'] ?? '0';
    final recipient = widget.uri.queryParameters['recipient'] ?? 'Unknown';
    final currency = widget.uri.queryParameters['currency'] ?? 'ToroG';
    final dappName =
        widget.uri.queryParameters['dappName'] ?? 'A third-party application';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Signature Request'),
        centerTitle: true,
        automaticallyImplyLeading:
            false, // Prevent back button, must explicitly reject or approve
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.link, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                '$dappName wants you to authorize a transaction.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    _buildRow('Action', 'Transfer Token'),
                    const Divider(color: AppColors.background),
                    _buildRow('Amount', '$amount $currency'),
                    const Divider(color: AppColors.background),
                    _buildRow('Recipient', recipient),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Wallet Password / PIN',
                hintText: 'Enter password to sign',
                isPassword: true,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSigning ? null : _onReject,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GradientButton(
                      text: 'Approve',
                      isLoading: _isSigning,
                      onPressed: _onApprove,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
