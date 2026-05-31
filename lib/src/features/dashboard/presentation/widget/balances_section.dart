import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tbank/src/features/dashboard/presentation/widget/token_icon.dart';
import 'package:toronet/toronet.dart';
import 'package:tbank/src/core/constants/constants.dart';
import 'package:tbank/src/features/dashboard/presentation/controllers/dashboard_controller.dart';

Currency _parseCurrency(String symbol) {
  switch (symbol.toUpperCase()) {
    case 'TOROG':
    case 'TORO':
      return Currency.toro;
    case 'USD':
    case 'USDC':
    case 'USDT':
      return Currency.dollar;
    case 'EUR':
      return Currency.euro;
    case 'GBP':
      return Currency.pound;
    case 'EGP':
      return Currency.egp;
    case 'KSH':
      return Currency.ksh;
    case 'ZAR':
      return Currency.zar;
    case 'ETH':
      return Currency.eth;
    case 'NGN':
    default:
      return Currency.naira;
  }
}

class BalancesSection extends StatelessWidget {
  final DashboardController dashboard;

  const BalancesSection({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final balances = dashboard.balances;
    
    // Display up to 3 balances inline
    final displayCount = balances.length > 3 ? 3 : balances.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Asset Balances',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            if (balances.length > 3)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/all_balances');
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View More',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (dashboard.isLoading && balances.isEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[700]!,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 50,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 80,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayCount,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final balance = balances[index];
              final currency = _parseCurrency(balance.symbol);
              final isToro = currency == Currency.toro;
              log(
                'Building balance card for ${balance.symbol} with amount ${balance.amount}',
              );
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isToro
                        ? AppColors.secondary.withOpacity(0.2)
                        : AppColors.primary.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        TokenIcon(currency: currency),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              balance.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              balance.symbol,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      balance.amount,
                      style: TextStyle(
                        color: isToro
                            ? AppColors.secondary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
