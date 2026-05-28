import 'package:flutter/material.dart';
import 'package:tbank/src/core/widgets/custom_text_field.dart';
import 'package:tbank/src/core/widgets/gradient_button.dart';
import 'package:tbank/src/features/onboarding/presentation/controllers/onboarding_controller.dart';

class ImportWalletTab extends StatelessWidget {
  const ImportWalletTab({
    super.key,
    required GlobalKey<FormState> importFormKey,
    required TextEditingController importKeyController,
    required TextEditingController importUsernameController,
    required TextEditingController importPasswordController,
    required this.controller,
  }) : _importFormKey = importFormKey,
       _importKeyController = importKeyController,
       _importUsernameController = importUsernameController,
       _importPasswordController = importPasswordController;

  final GlobalKey<FormState> _importFormKey;
  final TextEditingController _importKeyController;
  final TextEditingController _importUsernameController;
  final TextEditingController _importPasswordController;
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _importFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            labelText: 'Private Key',
            hintText: 'Enter 0x... hex key',
            controller: _importKeyController,
            prefixIcon: Icons.vpn_key_outlined,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Private key is required';
              }
              return null;
            },
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
          const SizedBox(height: 12),
          CustomTextField(
            labelText: 'Confirm Password',
            hintText: 'Password to encrypt key locally',
            controller: _importPasswordController,
            isPassword: true,
            prefixIcon: Icons.lock_outline,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Password is required';
              }
              return null;
            },
          ),
          const Spacer(),
          GradientButton(
            text: 'Import Credentials',
            isLoading: controller.isLoading,
            onPressed: () async {
              if (_importFormKey.currentState!.validate()) {
                await controller.importWallet(
                  privateKey: _importKeyController.text,
                  username: _importUsernameController.text,
                  password: _importPasswordController.text,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
