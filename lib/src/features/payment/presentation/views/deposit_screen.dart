import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/in_app_notification.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../controllers/payment_controller.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedCurrency = 'NGN';

  bool _isMainnetMode = false;
  bool _stepInitiated = false;
  String? _paymentRef;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeWallet = context.watch<OnboardingController>().activeWallet;
    final controller = context.watch<PaymentController>();

    if (activeWallet == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('ConnectW Deposit')),
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
                    // Custom Animated Toggle Switch
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Stack(
                        children: [
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            alignment: _isMainnetMode
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: 0.5,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.secondary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _isMainnetMode = false),
                                  child: Container(
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      style: TextStyle(
                                        color: !_isMainnetMode
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                        fontWeight: !_isMainnetMode
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      child: const Text('Testnet Faucet'),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _isMainnetMode = true),
                                  child: Container(
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      style: TextStyle(
                                        color: _isMainnetMode
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                        fontWeight: _isMainnetMode
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      child: const Text('Mainnet (Bank)'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_isMainnetMode) ...[
                      // Mainnet UI Mockup
                      const Text(
                        'ConnectW Live Deposit',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const CustomTextField(
                        labelText: 'Select Bank',
                        hintText: 'e.g. Guarantee Trust Bank',
                        prefixIcon: Icons.account_balance,
                      ),
                      const SizedBox(height: 16),
                      const CustomTextField(
                        labelText: 'Account Number',
                        hintText: '10-digit number',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.numbers,
                      ),
                      const SizedBox(height: 16),
                      const CustomTextField(
                        labelText: 'Deposit Amount (NGN)',
                        hintText: 'e.g. 50000',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.payments_outlined,
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        text: 'Deposit via ConnectW',
                        isLoading: false,
                        onPressed: () {
                          InAppNotification.show(
                            context,
                            'Mainnet ConnectW requires a live Merchant ID. Please use Testnet Faucet for hackathon testing.',
                            isError: true,
                          );
                        },
                      ),
                    ] else ...[
                      Text(
                        _stepInitiated
                            ? 'Step 2: Confirm Payment'
                            : 'Step 1: Initiate Deposit',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (!_stepInitiated) ...[
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0x12FFFFFF),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCurrency,
                                  dropdownColor: AppColors.surface,
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.primary,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                  ),
                                  items: AppConstants.supportedCurrencies.map((
                                    curr,
                                  ) {
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

                        // Amount Field
                        CustomTextField(
                          labelText: 'Deposit Amount',
                          hintText: 'e.g. 5000',
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefixIcon: Icons.add_card,
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
                        const SizedBox(height: 30),

                        GradientButton(
                          text: 'Initiate Transfer',
                          isLoading: controller.isLoading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final success = await controller.initiateDeposit(
                                amount: _amountController.text,
                                currency: _selectedCurrency,
                                address: activeWallet.address,
                              );
                              if (success) {
                                if (controller.isTestnet) {
                                  if (mounted) {
                                    // Fetch balances immediately in the background so the dashboard is fresh
                                    final dashboardController = context
                                        .read<DashboardController>();
                                    dashboardController.fetchBalances(
                                      activeWallet.address,
                                    );

                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: AppColors.surface,
                                        title: const Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle_outline,
                                              color: AppColors.success,
                                            ),
                                            SizedBox(width: 10),
                                            Text('Deposit Confirmed'),
                                          ],
                                        ),
                                        content: const Text(
                                          'Your testnet stablecoin has been minted and credited instantly to your wallet address.',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                context,
                                              ); // close dialog
                                              Navigator.pop(
                                                context,
                                              ); // return to dashboard
                                            },
                                            child: const Text(
                                              'Done',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                } else {
                                  setState(() {
                                    _stepInitiated = true;
                                    _paymentRef = controller.depositReference;
                                  });
                                }
                              } else if (mounted &&
                                  controller.errorMessage != null) {
                                InAppNotification.show(
                                  context,
                                  controller.errorMessage!,
                                  isError: true,
                                );
                              }
                            }
                          },
                        ),
                      ] else ...[
                        // Display Reference Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Deposit Reference ID:',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SelectableText(
                                _paymentRef ?? 'N/A',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Please complete the payment in the simulated browser gateway, then click confirm below to verify and settle.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        GradientButton(
                          text: 'Confirm Settle Deposit',
                          isLoading: controller.isLoading,
                          onPressed: () async {
                            if (_paymentRef != null) {
                              final verified = await controller.confirmDeposit(
                                paymentId: _paymentRef!,
                                amount: _amountController.text,
                              );

                              if (verified && mounted) {
                                final dashboardController = context
                                    .read<DashboardController>();
                                final address = activeWallet.address;

                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: AppColors.surface,
                                    title: const Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          color: AppColors.success,
                                        ),
                                        SizedBox(width: 10),
                                        Text('Deposit Confirmed'),
                                      ],
                                    ),
                                    content: const Text(
                                      'Your virtual fiat deposit was successfully confirmed. Balances will be updated shortly.',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          dashboardController.fetchBalances(
                                            address,
                                          );
                                          Navigator.pop(
                                            context,
                                          ); // close dialog
                                          Navigator.pop(
                                            context,
                                          ); // return to dashboard
                                        },
                                        child: const Text(
                                          'Done',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (mounted) {
                                final err =
                                    controller.errorMessage ??
                                    'Payment verification failed or pending.';
                                InAppNotification.show(
                                  context,
                                  err,
                                  isError: true,
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          child: const Text('Cancel / Start Over'),
                          onPressed: () {
                            setState(() {
                              _stepInitiated = false;
                              _paymentRef = null;
                              _amountController.clear();
                              controller.clearState();
                            });
                          },
                        ),
                      ],
                    ],
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
