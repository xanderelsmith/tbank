import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toronet/toronet.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/util/env.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../controllers/bridge_controller.dart';

class BridgeScreen extends StatefulWidget {
  const BridgeScreen({super.key});

  @override
  State<BridgeScreen> createState() => _BridgeScreenState();
}

class _BridgeScreenState extends State<BridgeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceAddressController = TextEditingController();
  final _contractAddressController = TextEditingController();
  final _tokenNameController = TextEditingController(text: 'USDC');
  final _amountController = TextEditingController();
  final _passwordController = TextEditingController();

  final List<String> _supportedChains = ['Polygon', 'Solana', 'BSC', 'Base', 'Arbitrum'];

  @override
  void initState() {
    super.initState();
    final activeWallet = context.read<OnboardingController>().activeWallet;
    if (activeWallet != null) {
      _sourceAddressController.text = activeWallet.address;
    }
  }

  @override
  void dispose() {
    _sourceAddressController.dispose();
    _contractAddressController.dispose();
    _tokenNameController.dispose();
    _amountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeWallet = context.watch<OnboardingController>().activeWallet;
    final controller = context.watch<BridgeController>();

    if (activeWallet == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cross-Chain Bridge'),
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
                      'Bridge Portal',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Source Chain Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Source Chain',
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
                              value: controller.selectedChain,
                              dropdownColor: AppColors.surface,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                              items: _supportedChains.map((chain) {
                                return DropdownMenuItem(
                                  value: chain,
                                  child: Text(chain),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.selectSourceChain(val);
                                  controller.fetchSourceBalance(activeWallet.address);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Balance Display on Source Chain
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${controller.selectedChain} Balance:',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        controller.isLoadingBalance
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)))
                            : Text(
                                '${controller.sourceBalance} ${_tokenNameController.text}',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                              ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Source Account Address
                    CustomTextField(
                      labelText: 'Source Account Address',
                      hintText: 'Enter address on source chain',
                      controller: _sourceAddressController,
                      prefixIcon: Icons.account_balance_wallet_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Source address is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Token Contract Address
                    CustomTextField(
                      labelText: 'Token Contract Address',
                      hintText: '0x... or token mint address',
                      controller: _contractAddressController,
                      prefixIcon: Icons.settings_ethernet,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Contract address is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Token Symbol & Amount
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            labelText: 'Token',
                            controller: _tokenNameController,
                            onChanged: (_) => setState(() {}),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: CustomTextField(
                            labelText: 'Amount',
                            hintText: '0.00',
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Required';
                              }
                              final num = double.tryParse(val);
                              if (num == null || num <= 0) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Fee Estimation Box
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceLight,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            if (_contractAddressController.text.isNotEmpty && _amountController.text.isNotEmpty) {
                              controller.estimateFee(
                                contractAddress: _contractAddressController.text,
                                amount: _amountController.text,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please fill contract address and amount to estimate fee.')),
                              );
                            }
                          },
                          child: controller.isEstimatingFee
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)))
                              : const Text('Estimate Fee', style: TextStyle(fontSize: 12)),
                        ),
                        Text(
                          'Gas Fee: ~${controller.estimatedFee} ToroG',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Password
                    CustomTextField(
                      labelText: 'Verification Password',
                      hintText: 'Enter local wallet password',
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
                      text: 'Execute Cross-Chain Bridge',
                      isLoading: controller.isLoading,
                      onPressed: () async {
                        if (Env.network == Network.testnet) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cross-chain bridging is only supported on the Mainnet. Coming soon to Testnet!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                          return;
                        }

                        if (_formKey.currentState!.validate()) {
                          final txHash = await controller.executeBridge(
                            fromAddress: _sourceAddressController.text,
                            password: _passwordController.text,
                            tokenName: _tokenNameController.text,
                            amount: _amountController.text,
                            contractAddress: _contractAddressController.text,
                          );

                          if (txHash != null && mounted) {
                            controller.clearState();
                            _amountController.clear();
                            _passwordController.clear();

                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppColors.surface,
                                title: const Row(
                                  children: [
                                    Icon(Icons.swap_calls, color: AppColors.primary),
                                    SizedBox(width: 10),
                                    Text('Bridging Initiated'),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your transfer is being locked on ${controller.selectedChain} and minted on Toronet. This may take a few minutes.',
                                      style: const TextStyle(color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Source Tx Signature:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                    child: const Text('Done', style: TextStyle(color: AppColors.primary)),
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
