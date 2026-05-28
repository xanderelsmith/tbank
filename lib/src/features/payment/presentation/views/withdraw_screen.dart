import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../controllers/payment_controller.dart';
import '../../domain/entities/bank_entity.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedCurrency = 'NGN';
  BankEntity? _selectedBank;
  bool _accountVerified = false;
  String? _resolvedAccountName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentController>().fetchBanks(_selectedCurrency);
    });
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _amountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeWallet = context.watch<OnboardingController>().activeWallet;
    final controller = context.watch<PaymentController>();

    if (activeWallet == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bank Withdrawal'),
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
                      'Payout Details',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Select Currency
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
                              items: ['NGN', 'USD'].map((curr) {
                                return DropdownMenuItem(
                                  value: curr,
                                  child: Text(curr),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedCurrency = val;
                                    _selectedBank = null;
                                    _accountVerified = false;
                                    _resolvedAccountName = null;
                                  });
                                  controller.fetchBanks(val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Select Bank
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Destination Bank',
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
                          child: controller.isLoadingBanks
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                                )
                              : DropdownButtonHideUnderline(
                                  child: DropdownButton<BankEntity>(
                                    hint: const Text('Choose a Bank'),
                                    value: _selectedBank,
                                    dropdownColor: AppColors.surface,
                                    isExpanded: true,
                                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                                    items: controller.banks.map((bank) {
                                      return DropdownMenuItem<BankEntity>(
                                        value: bank,
                                        child: Text(bank.name, overflow: TextOverflow.ellipsis),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedBank = val;
                                        _accountVerified = false;
                                        _resolvedAccountName = null;
                                      });
                                    },
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Account Number & Verify Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            labelText: 'Account Number',
                            hintText: '10-digit number',
                            controller: _accountNumberController,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.account_box_outlined,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Account is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surfaceLight,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _selectedBank == null
                                ? null
                                : () async {
                                    final name = await controller.verifyAccount(
                                      bankCode: _selectedBank!.code,
                                      accountNumber: _accountNumberController.text,
                                    );
                                    if (name != null) {
                                      setState(() {
                                        _accountVerified = true;
                                        _resolvedAccountName = name;
                                      });
                                    }
                                  },
                            child: controller.isVerifyingAccount
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)))
                                : const Text('Verify'),
                          ),
                        ),
                      ],
                    ),
                    
                    if (_accountVerified && _resolvedAccountName != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _resolvedAccountName!,
                                style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Amount
                    CustomTextField(
                      labelText: 'Amount to Withdraw',
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

                    // Password
                    CustomTextField(
                      labelText: 'Password',
                      hintText: 'Verify identity password',
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
                      text: 'Execute Withdrawal',
                      isLoading: controller.isLoading,
                      onPressed: !_accountVerified
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate() && _selectedBank != null) {
                                final txHash = await controller.executeWithdrawal(
                                  address: activeWallet.address,
                                  amount: _amountController.text,
                                  currency: _selectedCurrency,
                                  bankCode: _selectedBank!.code,
                                  accountNumber: _accountNumberController.text,
                                  accountName: _resolvedAccountName ?? '',
                                  password: _passwordController.text,
                                );

                                if (txHash != null && mounted) {
                                  controller.clearState();
                                  _amountController.clear();
                                  _accountNumberController.clear();
                                  _passwordController.clear();
                                  setState(() {
                                    _accountVerified = false;
                                    _resolvedAccountName = null;
                                  });

                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: AppColors.surface,
                                      title: const Row(
                                        children: [
                                          Icon(Icons.check_circle_outline, color: AppColors.success),
                                          SizedBox(width: 10),
                                          Text('Withdrawal Complete'),
                                        ],
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Your payout request was logged on-chain successfully.', style: TextStyle(color: AppColors.textSecondary)),
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
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
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
