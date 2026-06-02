import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../controllers/history_controller.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _typeFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeWallet = context.read<OnboardingController>().activeWallet;
      if (activeWallet != null) {
        context.read<HistoryController>().fetchTransactions(
          activeWallet.address,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeWallet = context.watch<OnboardingController>().activeWallet;
    final controller = context.watch<HistoryController>();

    if (activeWallet == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Filter transactions locally based on selected tab
    final filteredTxns = controller.transactions.where((tx) {
      if (_typeFilter == 'Sent') return tx.type == 'send';
      if (_typeFilter == 'Received') return tx.type == 'receive';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt, color: AppColors.primary),
            onPressed: () => controller.fetchTransactions(activeWallet.address),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            color: AppColors.surface.withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['All', 'Sent', 'Received'].map((type) {
                final isSelected = _typeFilter == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,

                  selectedColor: AppColors.primary.withOpacity(0.2),
                  backgroundColor: AppColors.surface,
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.white10,
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _typeFilter = type;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Main Transaction List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  controller.fetchTransactions(activeWallet.address),
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: controller.isLoading && controller.transactions.isEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[800]!,
                            highlightColor: Colors.grey[700]!,
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 140,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 100,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 15,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      width: 30,
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
                        );
                      },
                    )
                  : controller.errorMessage != null
                  ? Center(
                      child: Text(
                        'Error: ${controller.errorMessage}',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    )
                  : filteredTxns.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_toggle_off,
                            color: AppColors.textMuted,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No transactions found for $_typeFilter.',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: filteredTxns.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tx = filteredTxns[index];
                        final isSend = tx.type == 'send';

                        return GlassContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      (isSend
                                              ? AppColors.error
                                              : AppColors.success)
                                          .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isSend
                                      ? Icons.arrow_outward
                                      : Icons.call_received,
                                  color: isSend
                                      ? AppColors.error
                                      : AppColors.success,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                isSend
                                    ? 'Sent to: ${_formatAddress(tx.toAddress)}'
                                    : 'Received from: ${_formatAddress(tx.fromAddress)}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  _formatDate(tx.timestamp),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${isSend ? '-' : '+'}${tx.amount}',
                                    style: TextStyle(
                                      color: isSend
                                          ? AppColors.error
                                          : AppColors.success,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tx.currency.toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                const SizedBox(height: 12),
                                const Divider(color: Colors.white12, height: 1),
                                const SizedBox(height: 12),
                                _buildDetailRow(
                                  context,
                                  'Tx Hash',
                                  tx.txHash,
                                  copyable: true,
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                  context,
                                  'From',
                                  tx.fromAddress,
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(context, 'To', tx.toAddress),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                  context,
                                  'Status',
                                  tx.status.toUpperCase(),
                                  isStatus: true,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAddress(String addr) {
    if (addr == 'null' || addr.isEmpty || addr == '0x0000000000000000000000000000000000000000') {
      return 'System';
    }
    if (addr.length <= 12) return addr;
    return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool copyable = false,
    bool isStatus = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        Row(
          children: [
            Text(
              _formatAddress(value),
              style: TextStyle(
                color: isStatus ? AppColors.success : AppColors.textPrimary,
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (copyable) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied transaction hash'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Icon(
                  Icons.copy,
                  color: AppColors.primary,
                  size: 14,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
