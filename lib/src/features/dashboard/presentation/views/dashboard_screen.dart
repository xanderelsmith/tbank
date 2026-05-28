import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeWallet = context.read<OnboardingController>().activeWallet;
      if (activeWallet != null) {
        context.read<DashboardController>().fetchBalances(activeWallet.address);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingController>();
    final dashboard = context.watch<DashboardController>();
    final wallet = onboarding.activeWallet;

    if (wallet == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ToroBank'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => dashboard.fetchBalances(wallet.address),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () => onboarding.logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => dashboard.fetchBalances(wallet.address),
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Wallet Header Details Card
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_outline, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '@${wallet.username}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.success.withOpacity(0.2)),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Wallet Address',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            wallet.address,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: wallet.address));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Address copied to clipboard'),
                                backgroundColor: AppColors.success,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.copy, color: AppColors.textSecondary, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Balances Section
              const Text(
                'Asset Balances',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 12),
              
              if (dashboard.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (dashboard.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Failed to load balances: ${dashboard.errorMessage}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dashboard.balances.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final balance = dashboard.balances[index];
                    final isToroG = balance.symbol == 'ToroG';

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isToroG ? AppColors.secondary.withOpacity(0.2) : AppColors.primary.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: (isToroG ? AppColors.secondary : AppColors.primary).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isToroG ? Icons.local_fire_department : Icons.monetization_on,
                                  color: isToroG ? AppColors.secondary : AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    balance.name,
                                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    balance.symbol,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            balance.amount,
                            style: TextStyle(
                              color: isToroG ? AppColors.secondary : AppColors.textPrimary,
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
              const SizedBox(height: 32),

              // Action Cards / Grid
              const Text(
                'Financial Services',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 12),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.45,
                children: [
                  _buildActionCard(
                    context,
                    title: 'Send Value',
                    subtitle: 'Peer-to-peer transfer',
                    icon: Icons.send_rounded,
                    color: AppColors.primary,
                    route: '/transfer',
                  ),
                  _buildActionCard(
                    context,
                    title: 'Fiat Deposit',
                    subtitle: 'Fund via ConnectW',
                    icon: Icons.add_circle_outline,
                    color: AppColors.success,
                    route: '/deposit',
                  ),
                  _buildActionCard(
                    context,
                    title: 'Withdrawal',
                    subtitle: 'Bank payouts',
                    icon: Icons.account_balance_outlined,
                    color: AppColors.error,
                    route: '/withdraw',
                  ),
                  _buildActionCard(
                    context,
                    title: 'Virtual Card',
                    subtitle: 'Linked bank details',
                    icon: Icons.credit_card_outlined,
                    color: AppColors.accent,
                    route: '/virtual_wallet',
                  ),
                  _buildActionCard(
                    context,
                    title: 'Bridge Token',
                    subtitle: 'Cross-chain portal',
                    icon: Icons.swap_horiz_rounded,
                    color: Colors.purpleAccent,
                    route: '/bridge',
                  ),
                  _buildActionCard(
                    context,
                    title: 'Diagnostics',
                    subtitle: 'Developer node tools',
                    icon: Icons.developer_mode_outlined,
                    color: AppColors.secondary,
                    route: '/developer',
                  ),
                ],
              ),
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

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
