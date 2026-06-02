import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tbank/src/core/constants/constants.dart';
import 'package:tbank/src/core/widgets/custom_text_field.dart';
import 'package:tbank/src/core/widgets/enter_digit_pin_screen.dart';
import 'package:tbank/src/core/widgets/gradient_button.dart';
import 'package:tbank/src/core/widgets/in_app_notification.dart';
import 'package:tbank/src/features/onboarding/presentation/controllers/onboarding_controller.dart';

class CreateWalletNameScreen extends StatefulWidget {
  const CreateWalletNameScreen({super.key});

  @override
  State<CreateWalletNameScreen> createState() => _CreateWalletNameScreenState();
}

class _CreateWalletNameScreenState extends State<CreateWalletNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _onNext() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();

      // Navigate to enter PIN screen
      final pin = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => const EnterDigitPinScreen(
            title: 'Create Passcode',
            subtitle:
                'Add an extra layer of security to keep your crypto safe.',
          ),
        ),
      );

      if (pin != null && pin.length == 6) {
        // Proceed to create wallet
        if (mounted) {
          final controller = context.read<OnboardingController>();
          final mnemonic = await controller.createWalletWithSeed(
            username: username,
            pin: pin,
          );

          if (mnemonic != null && mounted) {
            _showSeedPhraseDialog(mnemonic);
          } else if (controller.errorMessage != null && mounted) {
            InAppNotification.show(
              context,
              controller.errorMessage!,
              isError: true,
            );
          }
        }
      }
    }
  }

  void _showSeedPhraseDialog(String mnemonic) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Save Your Seed Phrase!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Write down these 12 words. This is the ONLY way to recover your wallet.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                mnemonic,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Share.share('My Toronet Wallet Seed Phrase:\n\n$mnemonic');
            },
            child: const Text('Share'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to OnboardingStart
              // Since activeWallet is set, the wrapper will handle redirecting to Dashboard
            },
            child: const Text('I saved it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Create Wallet'),
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
                  'Choose your username',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This will be your Toronet Name Service (TNS) handle, allowing others to send funds easily to your name instead of a long address.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  labelText: 'TNS Username',
                  hintText: 'Enter unique username (e.g. alice)',
                  controller: _usernameController,
                  prefixIcon: Icons.alternate_email,
                  onChanged: (val) {
                    controller.checkTNSAvailability(val);
                  },
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                ),
                const Spacer(),
                GradientButton(
                  text: 'Next',
                  isLoading: controller.isLoading,
                  onPressed: _onNext,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
