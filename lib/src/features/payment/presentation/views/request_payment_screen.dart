import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tbank/src/core/constants/constants.dart';
import 'package:tbank/src/core/widgets/custom_text_field.dart';
import 'package:tbank/src/core/widgets/gradient_button.dart';
import 'package:tbank/src/core/widgets/in_app_notification.dart';
import 'package:tbank/src/features/onboarding/presentation/controllers/onboarding_controller.dart';

class RequestPaymentScreen extends StatefulWidget {
  const RequestPaymentScreen({super.key});

  @override
  State<RequestPaymentScreen> createState() => _RequestPaymentScreenState();
}

class _RequestPaymentScreenState extends State<RequestPaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedCurrency = 'ToroG';

  String _generateDeepLink(String walletAddress) {
    final amount = _amountController.text.trim();
    if (amount.isEmpty) return '';

    // e.g. torobank://sign-tx?amount=500&currency=NGN&recipient=0x...&dappName=Torobank%20User
    final uri = Uri(
      scheme: 'torobank',
      host: 'sign-tx',
      queryParameters: {
        'amount': amount,
        'currency': _selectedCurrency,
        'recipient': walletAddress,
        'dappName': 'Torobank User',
      },
    );

    return uri.toString();
  }

  void _shareLink(String link) {
    if (link.isEmpty) {
      InAppNotification.show(
        context,
        'Please enter a valid amount first',
        isError: true,
      );
      return;
    }
    SharePlus.instance.share(
      ShareParams(
        text:
            'Please pay $_selectedCurrency ${_amountController.text} to my Torobank wallet. Tap this link to authorize:\n\n$link',
        subject: 'Payment Request via Torobank',
      ),
    );
  }

  void _copyLink(String link) async {
    if (link.isEmpty) {
      InAppNotification.show(
        context,
        'Please enter a valid amount first',
        isError: true,
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: link));
    if (mounted) {
      InAppNotification.show(context, 'Payment link copied to clipboard!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingController>();
    final activeWallet = onboarding.activeWallet;

    if (activeWallet == null) {
      return const Scaffold(body: Center(child: Text('No active wallet')));
    }

    final currentLink = _generateDeepLink(activeWallet.address);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Request Payment'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.qr_code_2_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Generate a payment link to instantly request funds from anyone with Torobank.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),

                // Amount Field
                CustomTextField(
                  controller: _amountController,
                  labelText: 'Amount to Request',
                  hintText: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Amount is required';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Invalid amount';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() {}); // Re-generate link when amount changes
                  },
                ),
                const SizedBox(height: 20),

                // Currency Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCurrency,
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                      items: AppConstants.supportedCurrencies.map((
                        String currency,
                      ) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: Text(
                            currency,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCurrency = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Link Preview
                if (currentLink.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.secondary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Generated Link:',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentLink,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _copyLink(currentLink);
                          }
                        },
                        icon: const Icon(
                          Icons.copy,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        label: const Text(
                          'Copy Link',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GradientButton(
                        text: 'Share Link',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _shareLink(currentLink);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
