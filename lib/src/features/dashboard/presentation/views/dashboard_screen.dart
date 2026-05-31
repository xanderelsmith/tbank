import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toronet/toronet.dart';
import 'package:tbank/src/features/dashboard/presentation/widget/balances_section.dart';
import 'package:tbank/src/features/dashboard/presentation/widget/financial_services_grid.dart';
import 'package:tbank/src/features/dashboard/presentation/widget/wallet_header.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/util/env.dart';
import '../../../../core/widgets/in_app_notification.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    final dashboard = context.read<DashboardController>();
    dashboard.addListener(_onDashboardErrorListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onboarding = context.read<OnboardingController>();
      final activeWallet = onboarding.activeWallet;
      if (activeWallet != null) {
        dashboard.fetchBalances(activeWallet.address);
      }

      _notificationSubscription = onboarding.notificationService?.stream.listen(
        (notification) {
          if (!mounted) return;

          InAppNotification.show(
            context,
            '${notification.title}\n${notification.body}',
            isError: false,
          );

          if (activeWallet != null) {
            dashboard.fetchBalances(activeWallet.address);
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    context.read<DashboardController>().removeListener(
      _onDashboardErrorListener,
    );
    super.dispose();
  }

  void _onDashboardErrorListener() {
    if (!mounted) return;
    final dashboard = context.read<DashboardController>();
    final error = dashboard.errorMessage;
    if (error != null) {
      dashboard.clearError();
      InAppNotification.show(context, error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingController>();
    final dashboard = context.watch<DashboardController>();
    final wallet = onboarding.activeWallet;
    final isTestnet = Env.network == Network.testnet;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.history_rounded, color: AppColors.primary),
          onPressed: () {
            Navigator.pushNamed(context, '/history');
          },
        ),
        title: Row(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 28),
            const Text('ToroBank'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isTestnet ? AppColors.warning.withOpacity(0.2) : AppColors.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isTestnet ? AppColors.warning : AppColors.success,
                ),
              ),
              child: Text(
                isTestnet ? 'TESTNET' : 'MAINNET',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isTestnet ? AppColors.warning : AppColors.success,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (wallet != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              onPressed: () => dashboard.fetchBalances(wallet.address),
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () => onboarding.logout(),
          ),
        ],
      ),
      body: (wallet == null)
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => dashboard.fetchBalances(wallet.address),
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WalletHeader(
                      username: wallet.username,
                      address: wallet.address,
                    ),
                    const SizedBox(height: 28),
                    BalancesSection(dashboard: dashboard),
                    const SizedBox(height: 32),
                    FinancialServicesGrid(dashboard: dashboard),
                    const SizedBox(height: 16),

                    // View History Button
                    OutlinedButton.icon(
                      icon: const Icon(Icons.history, size: 20),
                      label: const Text('View Transaction History'),
                      onPressed: () => Navigator.pushNamed(context, '/history'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
