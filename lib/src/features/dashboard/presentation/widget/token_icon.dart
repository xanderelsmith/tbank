import 'package:flutter/material.dart';
import 'package:tbank/src/core/constants/constants.dart';
import 'package:toronet/toronet.dart';

class TokenIcon extends StatelessWidget {
  final Currency currency;

  const TokenIcon({super.key, required this.currency});

  @override
  Widget build(BuildContext context) {
    Widget iconContent;
    Color bgColor;

    switch (currency) {
      case Currency.toro:
        iconContent = const Icon(
          Icons.local_fire_department,
          color: AppColors.secondary,
          size: 24,
        );
        bgColor = AppColors.secondary.withOpacity(0.1);
        break;
      case Currency.dollar:
        iconContent = const Icon(
          Icons.attach_money,
          color: AppColors.primary,
          size: 24,
        );
        bgColor = AppColors.primary.withOpacity(0.1);
        break;
      case Currency.euro:
        iconContent = const Icon(
          Icons.euro,
          color: AppColors.primary,
          size: 24,
        );
        bgColor = AppColors.primary.withOpacity(0.1);
        break;
      case Currency.pound:
        iconContent = const Icon(
          Icons.currency_pound,
          color: AppColors.primary,
          size: 24,
        );
        bgColor = AppColors.primary.withOpacity(0.1);
        break;
      // Example of adding an image asset for a new token:
      case Currency.naira:
        iconContent = Text(
          '₦',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        );
        bgColor = Colors.blue.withOpacity(0.1);
        break;
      default:
        iconContent = const Icon(
          Icons.monetization_on,
          color: AppColors.primary,
          size: 24,
        );
        bgColor = AppColors.primary.withOpacity(0.1);
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(child: iconContent),
    );
  }
}
