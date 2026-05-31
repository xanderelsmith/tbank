import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tbank/src/core/constants/constants.dart';
import 'package:tbank/src/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:tbank/src/features/dashboard/presentation/widget/token_icon.dart';
import 'package:toronet/toronet.dart';

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

class AllBalancesScreen extends StatelessWidget {
  const AllBalancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardController>();
    final balances = dashboard.balances;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Asset Balances'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView.separated(
          itemCount: balances.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final balance = balances[index];
            final currency = _parseCurrency(balance.symbol);
            final isToro = currency == Currency.toro;

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
      ),
    );
  }
}
