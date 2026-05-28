import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../controllers/transfer_controller.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedCurrency = 'USD';

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeWallet = context.watch<OnboardingController>().activeWallet;
    final controller = context.watch<TransferController>();

    if (activeWallet == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Send Value'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Transaction Details',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recipient Field
                    CustomTextField(
                      labelText: 'Recipient TNS Username or Address',
                      hintText: 'e.g. bob or 0x...',
                      controller: _recipientController,
                      prefixIcon: Icons.person_outline,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Recipient is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Currency Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Currency',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x12FFFFFF)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCurrency,
                              dropdownColor: AppColors.surface,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                              items: ['USD', 'NGN', 'TOROG'].map((curr) {
                                return DropdownMenuItem(
                                  value: curr,
                                  child: Text(curr),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedCurrency = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Amount
                    CustomTextField(
                      labelText: 'Amount to Send',
                      hintText: '0.00',
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.attach_money,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Amount is required';
                        }
                        final num = double.tryParse(val);
                        if (num == null || num <= 0) {
                          return 'Enter a valid positive number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    CustomTextField(
                      labelText: 'Verification Password',
                      hintText: 'Enter password to sign tx',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    if (controller.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Text(
                          controller.errorMessage!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    GradientButton(
                      text: 'Authorize Transfer',
                      isLoading: controller.isLoading || controller.isResolvingTNS,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // First resolve recipient address
                          final recipientAddress = await controller.resolveRecipient(_recipientController.text);
                          if (recipientAddress == null) return;

                          // Execute transfer
                          final txHash = await controller.executeTransfer(
                            fromAddress: activeWallet.address,
                            toAddress: recipientAddress,
                            amount: _amountController.text,
                            currency: _selectedCurrency,
                            password: _passwordController.text,
                          );

                          if (txHash != null && mounted) {
                            controller.clearState();
                            _recipientController.clear();
                            _amountController.clear();
                            _passwordController.clear();
                            
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppColors.surface,
                                title: const Row(
                                  children: [
                                    Icon(Icons.check_circle_outline, color: AppColors.success),
                                    SizedBox(width: 10),
                                    Text('Transfer Completed'),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Your transaction was successfully processed.', style: TextStyle(color: AppColors.textSecondary)),
                                    const SizedBox(height: 16),
                                    const Text('Transaction Hash:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    SelectableText(
                                      txHash,
                                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK', style: TextStyle(color: AppColors.primary)),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
