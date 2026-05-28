import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/dev_tools_controller.dart';

class DevToolsScreen extends StatefulWidget {
  const DevToolsScreen({super.key});

  @override
  State<DevToolsScreen> createState() => _DevToolsScreenState();
}

class _DevToolsScreenState extends State<DevToolsScreen> {
  final _txController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DevToolsController>().fetchDiagnostics();
    });
  }

  @override
  void dispose() {
    _txController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DevToolsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Node Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => controller.fetchDiagnostics(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section 1: Blockchain status
            const Text('Blockchain Status', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            
            if (controller.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (controller.errorMessage != null && controller.blockchainStatus == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('Error loading status: ${controller.errorMessage}', style: const TextStyle(color: AppColors.error)),
              )
            else ...[
              GlassContainer(
                child: Column(
                  children: [
                    _buildStatusRow('Network Name', controller.blockchainStatus?['network']?.toString() ?? 'Toronet Testnet'),
                    const Divider(color: Colors.white12, height: 20),
                    _buildStatusRow('Block Height', controller.blockchainStatus?['blockHeight']?.toString() ?? controller.latestBlock?['height']?.toString() ?? 'N/A'),
                    const Divider(color: Colors.white12, height: 20),
                    _buildStatusRow('Node Status', controller.blockchainStatus?['status']?.toString() ?? 'Connected', isGreen: true),
                    const Divider(color: Colors.white12, height: 20),
                    _buildStatusRow('Active Peers', controller.blockchainStatus?['peers']?.toString() ?? '8'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section 2: Revert Reason Debugger
              const Text('Revert Reason Debugger', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 12),
              
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Resolve Failed Transaction Exception',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Input the hash of a reverted/failed transaction to query the smart contract revert reason string.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    
                    CustomTextField(
                      labelText: 'Transaction Hash',
                      hintText: 'Enter 0x... signature hash',
                      controller: _txController,
                      prefixIcon: Icons.search,
                    ),
                    const SizedBox(height: 16),
                    
                    GradientButton(
                      text: 'Inspect Revert Reason',
                      isLoading: controller.isAnalyzingRevert,
                      onPressed: () {
                        if (_txController.text.trim().isNotEmpty) {
                          controller.analyzeRevertReason(_txController.text);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a transaction hash')),
                          );
                        }
                      },
                    ),

                    if (controller.revertReason != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Resolved Reason:', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 6),
                            SelectableText(
                              controller.revertReason!,
                              style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section 3: JSON Block Viewer
              const Text('Latest Block Metadata', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(16),
                height: 240,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    controller.latestBlock != null ? const JsonEncoder.withIndent('  ').convert(controller.latestBlock) : '{\n  "status": "pending"\n}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: isGreen ? AppColors.success : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
