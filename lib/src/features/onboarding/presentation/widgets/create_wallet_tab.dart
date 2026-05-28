import 'package:flutter/material.dart';
import 'package:tbank/src/core/widgets/custom_text_field.dart';
import 'package:tbank/src/features/onboarding/presentation/controllers/onboarding_controller.dart';
import '../../../../core/widgets/gradient_button.dart';

class CreateWalletTab extends StatelessWidget {
  const CreateWalletTab({
    super.key,
    required GlobalKey<FormState> createFormKey,
    required TextEditingController usernameController,
    required this.controller,
    required TextEditingController confirmController,
    required TextEditingController passwordController,
  }) : _createFormKey = createFormKey,
       _usernameController = usernameController,
       _passwordController = passwordController,
       _confirmController = confirmController;

  final GlobalKey<FormState> _createFormKey;
  final TextEditingController _usernameController;
  final OnboardingController controller;
  final TextEditingController _passwordController;
  final TextEditingController _confirmController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _createFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          const SizedBox(height: 16),
          CustomTextField(
            labelText: 'Password',
            hintText: 'Enter wallet encryption password',
            controller: _passwordController,
            isPassword: true,
            prefixIcon: Icons.lock_outline,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Password is required';
              }
              if (val.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            labelText: 'Confirm Password',
            hintText: 'Enter wallet encryption password',
            controller: _confirmController,
            isPassword: true,
            prefixIcon: Icons.lock_outline,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Password is required';
              }
              if (val != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),

          const Spacer(),
          GradientButton(
            text: 'Generate Wallet',
            isLoading: controller.isLoading,
            onPressed: () async {
              if (_createFormKey.currentState!.validate()) {
                await controller.createWallet(
                  username: _usernameController.text,
                  password: _passwordController.text,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
