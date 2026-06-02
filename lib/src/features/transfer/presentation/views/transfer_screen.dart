import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/pin_input_field.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../../core/widgets/in_app_notification.dart';
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
  final _pinController = TextEditingController();
  String _selectedCurrency = 'USD';

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _pinController.dispose();
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
                              items: AppConstants.supportedCurrencies.map((curr) {
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

                    PinInputField(
                      labelText: '6-Digit PIN',
                      hintText: 'Tap to enter PIN to sign tx',
                      controller: _pinController,
                      validator: (val) {
                        if (val == null || val.trim().length != 6) {
                          return 'A 6-digit PIN is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    GradientButton(
                      text: 'Authorize Transfer',
                      isLoading: controller.isLoading || controller.isResolvingTNS,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // First resolve recipient address
                          final recipientAddress = await controller.resolveRecipient(_recipientController.text);
                          if (recipientAddress == null) {
                            if (mounted && controller.errorMessage != null) {
                              InAppNotification.show(
                                context,
                                controller.errorMessage!,
                                isError: true,
                              );
                            }
                            return;
                          }

                          // Execute transfer
                          final txHash = await controller.executeTransfer(
                            fromAddress: activeWallet.address,
                            toAddress: recipientAddress,
                            amount: _amountController.text,
                            currency: _selectedCurrency,
                            password: _pinController.text,
                          );

                          if (txHash != null && mounted) {
                            final dashboardController = context.read<DashboardController>();
                            final address = activeWallet.address;

                            controller.clearState();
                            _recipientController.clear();
                            _amountController.clear();
                            _pinController.clear();
                            
                            showDialog(
                              context: context,
                              barrierDismissible: false,
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
                                    onPressed: () {
                                      dashboardController.fetchBalances(address);
                                      Navigator.pop(context); // close dialog
                                      Navigator.pop(context); // return to dashboard
                                    },
                                    child: const Text('OK', style: TextStyle(color: AppColors.primary)),
                                  ),
                                ],
                              ),
                            );
                          } else if (mounted && controller.errorMessage != null) {
                            InAppNotification.show(
                              context,
                              controller.errorMessage!,
                              isError: true,
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
