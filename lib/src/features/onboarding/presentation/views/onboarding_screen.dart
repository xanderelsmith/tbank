import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tbank/src/core/constants/appimages.dart';
import 'package:tbank/src/features/onboarding/presentation/widgets/create_wallet_tab.dart';
import 'package:tbank/src/features/onboarding/presentation/widgets/import_wallet_tab.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/glass_container.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _createFormKey = GlobalKey<FormState>();
  final _importFormKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _importKeyController = TextEditingController();
  final _importUsernameController = TextEditingController();
  final _importPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _importKeyController.dispose();
    _importUsernameController.dispose();
    _importPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.background),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 64,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Section
                      Center(child: Image.asset(AppImages.logo)),
                      const SizedBox(height: 24),
                      const Text(
                        'ToroBank',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Developer Clean Architecture Template for Toronet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Tabs & Forms
                      GlassContainer(
                        height: 500,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: TabBar(
                                controller: _tabController,
                                indicatorColor: AppColors.primary,
                                labelColor: AppColors.primary,
                                unselectedLabelColor: AppColors.textSecondary,
                                indicatorSize: TabBarIndicatorSize.tab,
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                tabs: const [
                                  Tab(text: 'Create Wallet'),
                                  Tab(text: 'Import Wallet'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            SizedBox(
                              height: 400,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  // Create tab
                                  CreateWalletTab(
                                    createFormKey: _createFormKey,
                                    usernameController: _usernameController,
                                    controller: controller,
                                    confirmController: _confirmController,
                                    passwordController: _passwordController,
                                  ),

                                  // Import tab
                                  ImportWalletTab(
                                    importFormKey: _importFormKey,
                                    importKeyController: _importKeyController,
                                    importUsernameController:
                                        _importUsernameController,
                                    importPasswordController:
                                        _importPasswordController,
                                    controller: controller,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
