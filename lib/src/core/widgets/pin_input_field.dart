import 'package:flutter/material.dart';
import 'package:tbank/src/core/widgets/custom_text_field.dart';
import 'package:tbank/src/core/widgets/enter_digit_pin_screen.dart';

class PinInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final FormFieldValidator<String>? validator;

  const PinInputField({
    super.key,
    required this.controller,
    this.labelText = '6-Digit PIN',
    this.hintText = 'Tap to enter PIN',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      isPassword: true,
      readOnly: true,
      prefixIcon: Icons.lock_outline,
      validator: validator,
      onTap: () async {
        final pin = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => const EnterDigitPinScreen(
              title: 'Enter PIN',
              subtitle: 'Please enter your 6-digit secure PIN',
            ),
          ),
        );
        if (pin != null && pin.length == 6) {
          controller.text = pin;
        }
      },
    );
  }
}
