import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tbank/src/core/constants/constants.dart';
import 'package:tbank/src/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:tbank/src/features/dashboard/presentation/views/dashboard_screen.dart';
import 'package:tbank/src/features/dashboard/presentation/widget/action_card.dart';

class FinancialServicesGrid extends StatelessWidget {
  final DashboardController dashboard;

  const FinancialServicesGrid({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Financial Services',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        if (dashboard.isLoading && dashboard.balances.isEmpty)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.19,
            children: List.generate(
              7,
              (index) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[700]!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 100,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        else
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.19,
            children: [
              const ActionCard(
                title: 'Send Value',
                subtitle: 'Peer-to-peer transfer',
                icon: Icons.send_rounded,
                color: AppColors.primary,
                route: '/transfer',
              ),
              const ActionCard(
                title: 'Fiat Deposit',
                subtitle: 'Fund via ConnectW',
                icon: Icons.add_circle_outline,
                color: AppColors.success,
                route: '/deposit',
              ),
              const ActionCard(
                title: 'Withdrawal',
                subtitle: 'Bank payouts',
                icon: Icons.account_balance_outlined,
                color: AppColors.error,
                route: '/withdraw',
              ),
              const ActionCard(
                title: 'Request',
                subtitle: 'Payment link generator',
                icon: Icons.qr_code_2_rounded,
                color: AppColors.primary,
                route: '/request',
              ),
              const ActionCard(
                title: 'Virtual Card',
                subtitle: 'Linked bank details',
                icon: Icons.credit_card_outlined,
                color: AppColors.accent,
                route: '/virtual_wallet',
              ),
              const ActionCard(
                title: 'Bridge Token',
                subtitle: 'Cross-chain portal',
                icon: Icons.swap_horiz_rounded,
                color: Colors.purpleAccent,
                route: '/bridge',
              ),
              const ActionCard(
                title: 'Diagnostics',
                subtitle: 'Developer node tools',
                icon: Icons.developer_mode_outlined,
                color: AppColors.secondary,
                route: '/developer',
              ),
            ],
          ),
      ],
    );
  }
}
