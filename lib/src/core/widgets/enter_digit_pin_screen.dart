import 'package:flutter/material.dart';
import 'package:tbank/src/core/constants/constants.dart';
import 'package:tbank/src/core/util/app_screenutils.dart';
import 'package:tbank/src/core/widgets/custom_keypad.dart';

class EnterDigitPinScreen extends StatefulWidget {
  const EnterDigitPinScreen({
    super.key,
    required this.title,
    required this.subtitle,
  });
  
  final String title;
  final String subtitle;

  @override
  State<EnterDigitPinScreen> createState() => _EnterDigitPinScreenState();
}

class _EnterDigitPinScreenState extends State<EnterDigitPinScreen> {
  String value = '';
  bool _obscurePin = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _obscurePin ? Icons.visibility_off : Icons.visibility,
              color: isDark ? AppColors.white : AppColors.c_3D3D3D,
            ),
            onPressed: () {
              setState(() {
                _obscurePin = !_obscurePin;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _buildPinDot(index, isDark),
                ),
              ),
            ),
            const Spacer(),
            CustomNumKeyPad(
              rightIcon: const Icon(Icons.backspace_outlined),
              size: Size(AppScreenUtils.screenSize(context).width / 4, 63),
              textColor: isDark ? AppColors.white : const Color(0xff525866),
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : const Color(0xffF3F3F3),
              ),
              leftButtonFn: () {
                // Could be used for a biometric icon or left empty
              },
              rightButtonFn: () {
                if (value.isNotEmpty) {
                  setState(() {
                    value = value.substring(0, value.length - 1);
                  });
                }
              },
              rightButtonLongPressFn: () {
                setState(() {
                  value = '';
                });
              },
              onNumTap: (number) {
                if (value.length < 6) {
                  setState(() {
                    value += number;
                  });
                  // Auto submit when 6 digits are reached
                  if (value.length == 6) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        Navigator.pop(context, value);
                      }
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDot(int index, bool isDark) {
    final bool hasDigit = value.length > index;

    if (hasDigit && !_obscurePin) {
      // Show the actual number
      return Container(
        width: 20,
        height: 24,
        alignment: Alignment.center,
        child: Text(
          value[index],
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.white : Colors.black,
          ),
        ),
      );
    } else {
      // Show dot
      return Container(
        decoration: BoxDecoration(
          color: hasDigit ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: hasDigit
                ? AppColors.primary
                : isDark
                    ? Colors.white54
                    : Colors.black26,
            width: 1.5,
          ),
          shape: BoxShape.circle,
        ),
        width: 16,
        height: 16,
      );
    }
  }
}
