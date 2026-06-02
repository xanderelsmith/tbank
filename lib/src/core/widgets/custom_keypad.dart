import 'package:flutter/material.dart';
import 'package:tbank/src/core/constants/constants.dart';

class CustomNumKeyPad extends StatelessWidget {
  const CustomNumKeyPad({
    super.key,
    required this.leftButtonFn,
    required this.rightButtonFn,
    required this.rightButtonLongPressFn,
    required this.onNumTap,
    this.decoration,
    this.size,
    this.leftIcon,
    this.rightIcon,
    this.mainAxisAlignment,
    this.textColor,
  });

  final Function()? leftButtonFn;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final Color? textColor;
  final Size? size;
  final Function()? rightButtonFn;
  final Decoration? decoration;
  final Function(String value) onNumTap;
  final Function()? rightButtonLongPressFn;
  final MainAxisAlignment? mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.spaceBetween,
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        children: List.generate(12, (index) {
          if (index == 9) {
            return GestureDetector(
              onTap: leftButtonFn,
              child: Container(
                margin: const EdgeInsets.only(bottom: 7),
                decoration: decoration,
                alignment: Alignment.center,
                width: size != null ? size!.width : 50,
                height: size != null ? size!.height : 50,
                child: leftIcon,
              ),
            );
          } else if (index == 10) {
            return calcButton(
              '0',
              (value) {
                onNumTap(value);
              },
              decoration: decoration,
              size: size,
              context: context,
              textColor: textColor,
            );
          } else if (index == 11) {
            return InkWell(
              borderRadius: BorderRadius.circular(45),
              onTap: rightButtonFn,
              onLongPress: rightButtonLongPressFn,
              child: Container(
                margin: const EdgeInsets.only(bottom: 7),
                decoration: decoration,
                alignment: Alignment.center,
                width: size != null ? size!.width : 50,
                height: size != null ? size!.height : 50,
                child: Icon(Icons.backspace_outlined, color: textColor ?? AppColors.textPrimary),
              ),
            );
          } else {
            return calcButton(
              (index + 1).toString(),
              (value) {
                onNumTap(value);
              },
              decoration: decoration,
              size: size,
              context: context,
              textColor: textColor,
            );
          }
        }),
      ),
    );
  }
}

Widget calcButton(
  String value,
  Function(String value) onNumTap, {
  Decoration? decoration,
  Size? size,
  required BuildContext context,
  Color? textColor,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: () {
      onNumTap(value);
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: decoration,
      alignment: Alignment.center,
      width: size != null ? size.width : 50,
      height: size != null ? size.height : 50,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
    ),
  );
}
