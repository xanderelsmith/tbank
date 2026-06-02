import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tbank/src/core/constants/constants.dart';
import 'package:tbank/src/core/widgets/custom_text_field.dart';
import 'package:tbank/src/core/widgets/enter_digit_pin_screen.dart';
import 'package:tbank/src/core/widgets/gradient_button.dart';
import 'package:tbank/src/core/widgets/in_app_notification.dart';
import 'package:tbank/src/features/onboarding/presentation/controllers/onboarding_controller.dart';

class ImportWalletScreen extends StatefulWidget {
  const ImportWalletScreen({super.key});

  @override
  State<ImportWalletScreen> createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _importKeyController = TextEditingController();
  final _importUsernameController = TextEditingController();

  @override
  void dispose() {
    _importKeyController.dispose();
    _importUsernameController.dispose();
    super.dispose();
  }

  void _onImport() async {
    if (_formKey.currentState!.validate()) {
      // First, get the PIN to encrypt the imported key locally
      final pin = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => const EnterDigitPinScreen(
            title: 'Create Passcode',
            subtitle: 'This PIN will be used to encrypt your imported key locally on this device.',
          ),
        ),
      );

      if (pin != null && pin.length == 6) {
        if (mounted) {
          final controller = context.read<OnboardingController>();
          try {
            await controller.importWallet(
              input: _importKeyController.text.trim(),
              username: _importUsernameController.text.trim(),
              password: pin,
            );
            
            if (mounted && controller.errorMessage == null) {
              // Successfully imported, pop back to trigger dashboard redirect
              Navigator.pop(context);
            } else if (mounted && controller.errorMessage != null) {
              InAppNotification.show(
                context,
                controller.errorMessage!,
                isError: true,
              );
            }
          } catch (e) {
            if (mounted) {
              InAppNotification.show(
                context,
                e.toString(),
                isError: true,
              );
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Import Wallet'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Import existing wallet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your 12-word seed phrase or private key to restore your wallet.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  labelText: 'Private Key or Seed Phrase',
                  hintText: 'Enter 0x... hex key or 12 words',
                  controller: _importKeyController,
                  prefixIcon: Icons.vpn_key_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Private key or seed phrase is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Need a test key? Click to generate a random EVM-compatible private key.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        final random = Random.secure();
                        final values = List<int>.generate(32, (i) => random.nextInt(256));
                        final hexString = '0x${values.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join()}';
                        _importKeyController.text = hexString;
                      },
                      icon: const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                      label: const Text(
                        'Generate Test Key',
                        style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  labelText: 'TNS Username',
                  hintText: 'Assign local username',
                  controller: _importUsernameController,
                  prefixIcon: Icons.alternate_email,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                ),
                const Spacer(),
                GradientButton(
                  text: 'Import Credentials',
                  isLoading: controller.isLoading,
                  onPressed: _onImport,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
