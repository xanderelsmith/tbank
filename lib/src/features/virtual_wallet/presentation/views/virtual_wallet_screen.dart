import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tbank/src/core/util/env.dart';
import 'package:toronet/toronet.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../controllers/virtual_wallet_controller.dart';

class VirtualWalletScreen extends StatefulWidget {
  const VirtualWalletScreen({super.key});

  @override
  State<VirtualWalletScreen> createState() => _VirtualWalletScreenState();
}

class _VirtualWalletScreenState extends State<VirtualWalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeWallet = context.read<OnboardingController>().activeWallet;
      if (activeWallet != null) {
        context.read<VirtualWalletController>().fetchVirtualAccount(
          activeWallet.address,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeWallet = context.watch<OnboardingController>().activeWallet;
    final controller = context.watch<VirtualWalletController>();

    if (activeWallet == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final vAccount = controller.virtualAccount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Virtual Card')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (controller.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80.0),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (vAccount == null) ...[
              // Setup Card UI
              GlassContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.credit_card_off_outlined,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Active Virtual Card',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Generate a virtual bank account linked to your Toronet address to accept payments directly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (controller.errorMessage != null) ...[
                      Text(
                        controller.errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    GradientButton(
                      text: 'Create Virtual Account',
                      onPressed: () {
                        if (Env.network == Network.testnet) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Virtual cards are only supported on the Mainnet. Coming soon to Testnet!',
                              ),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        } else {
                          controller.createVirtualAccount(activeWallet.address);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Card Graphic Section
              Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Card mesh pattern simulation
                    Positioned(
                      right: -30,
                      bottom: -30,
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(
                          Icons.blur_circular,
                          size: 240,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                vAccount.bankName.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  fontSize: 15,
                                ),
                              ),
                              const Icon(
                                Icons.contactless,
                                color: AppColors.background,
                                size: 28,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatCardNumber(vAccount.accountNumber),
                                style: const TextStyle(
                                  color: AppColors.background,
                                  fontSize: 22,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'ACCOUNT NUMBER',
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vAccount.accountName.toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.background,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'CARDHOLDER NAME',
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 44,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Center(
                                  child: Text(
                                    'TNS',
                                    style: TextStyle(
                                      color: AppColors.background,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Detail Fields Table
              const Text(
                'Routing Information',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),

              GlassContainer(
                child: Column(
                  children: [
                    _buildDetailRow('Institution', vAccount.bankName),
                    const Divider(color: Colors.white12, height: 24),
                    _buildDetailRow(
                      'Account No.',
                      vAccount.accountNumber,
                      onCopy: () {
                        Clipboard.setData(
                          ClipboardData(text: vAccount.accountNumber),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account number copied'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    _buildDetailRow('Account Name', vAccount.accountName),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.12),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Incoming bank transfers made to this virtual account are settled to your Toronet Naira wallet address automatically.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCardNumber(String num) {
    if (num.length <= 4) return num;
    final buffer = StringBuffer();
    for (int i = 0; i < num.length; i++) {
      buffer.write(num[i]);
      if ((i + 1) % 4 == 0 && i != num.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  Widget _buildDetailRow(String label, String value, {VoidCallback? onCopy}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
            if (onCopy != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onCopy,
                child: const Icon(
                  Icons.copy,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
