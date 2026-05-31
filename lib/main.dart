import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'src/core/constants/constants.dart';
import 'src/core/services/toronet_client.dart';
import 'src/core/services/deep_link_service.dart';

// Onboarding Feature
import 'src/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'src/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'src/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'src/features/onboarding/presentation/views/onboarding_screen.dart';

// Dashboard Feature
import 'src/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'src/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'src/features/dashboard/presentation/views/dashboard_screen.dart';
import 'src/features/dashboard/presentation/views/all_balances_screen.dart';

// Transfer Feature
import 'src/features/transfer/data/repositories/transfer_repository_impl.dart';
import 'src/features/transfer/presentation/controllers/transfer_controller.dart';
import 'src/features/transfer/presentation/views/transfer_screen.dart';

// Payment Feature
import 'src/features/payment/data/repositories/payment_repository_impl.dart';
import 'src/features/payment/presentation/controllers/payment_controller.dart';
import 'src/features/payment/presentation/views/deposit_screen.dart';
import 'src/features/payment/presentation/views/withdraw_screen.dart';
import 'src/features/payment/presentation/views/request_payment_screen.dart';

// Virtual Wallet Feature
import 'src/features/virtual_wallet/data/repositories/virtual_wallet_repository_impl.dart';
import 'src/features/virtual_wallet/presentation/controllers/virtual_wallet_controller.dart';
import 'src/features/virtual_wallet/presentation/views/virtual_wallet_screen.dart';

// Bridge Feature
import 'src/features/bridge/data/repositories/bridge_repository_impl.dart';
import 'src/features/bridge/presentation/controllers/bridge_controller.dart';
import 'src/features/bridge/presentation/views/bridge_screen.dart';

// History Feature
import 'src/features/history/data/repositories/history_repository_impl.dart';
import 'src/features/history/presentation/controllers/history_controller.dart';
import 'src/features/history/presentation/views/history_screen.dart';

// Developer/Diagnostics Feature
import 'src/features/developer/data/repositories/dev_tools_repository_impl.dart';
import 'src/features/developer/presentation/controllers/dev_tools_controller.dart';
import 'src/features/developer/presentation/views/dev_tools_screen.dart';

// Wallet Connect Feature
import 'src/features/wallet_connect/presentation/views/transaction_approval_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load configuration from .env file
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(
      "Warning: Could not load .env file. Falling back to platform variables. Error: $e",
    );
  }

  // Initialize service client
  final toronetClient = ToronetClient();

  final sharedPreferences = await SharedPreferences.getInstance();

  // Wire repositories
  var onboardingLocalDataSourceImpl = OnboardingLocalDataSourceImpl(
    sharedPreferences,
  );
  final onboardingRepo = OnboardingRepositoryImpl(
    client: toronetClient,
    localDataSource: onboardingLocalDataSourceImpl,
  );
  final dashboardRepo = DashboardRepositoryImpl(toronetClient);
  final transferRepo = TransferRepositoryImpl(toronetClient);
  final paymentRepo = PaymentRepositoryImpl(toronetClient);
  final virtualWalletRepo = VirtualWalletRepositoryImpl(toronetClient);
  final bridgeRepo = BridgeRepositoryImpl(toronetClient);
  final historyRepo = HistoryRepositoryImpl(toronetClient);
  final devToolsRepo = DevToolsRepositoryImpl(toronetClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => OnboardingController(onboardingRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardController(dashboardRepo),
        ),
        ChangeNotifierProvider(create: (_) => TransferController(transferRepo)),
        ChangeNotifierProvider(create: (_) => PaymentController(paymentRepo)),
        ChangeNotifierProvider(
          create: (_) => VirtualWalletController(virtualWalletRepo),
        ),
        ChangeNotifierProvider(create: (_) => BridgeController(bridgeRepo)),
        ChangeNotifierProvider(create: (_) => HistoryController(historyRepo)),
        ChangeNotifierProvider(create: (_) => DevToolsController(devToolsRepo)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late DeepLinkService _deepLinkService;

  @override
  void initState() {
    super.initState();
    _deepLinkService = DeepLinkService();
    _deepLinkService.uriStream.listen((uri) {
      if (uri.scheme == 'torobank' && uri.host == 'sign-tx') {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => TransactionApprovalScreen(uri: uri),
            fullscreenDialog: true,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingController>();

    return MaterialApp(
      title: 'ToroBank Developer Template',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: AppTheme.darkTheme,
      home: onboarding.activeWallet == null
          ? const OnboardingScreen()
          : const DashboardScreen(),
      routes: {
        '/transfer': (_) => const TransferScreen(),
        '/deposit': (_) => const DepositScreen(),
        '/withdraw': (_) => const WithdrawScreen(),
        '/request': (_) => const RequestPaymentScreen(),
        '/virtual_wallet': (_) => const VirtualWalletScreen(),
        '/bridge': (_) => const BridgeScreen(),
        '/history': (_) => const HistoryScreen(),
        '/developer': (_) => const DevToolsScreen(),
        '/all_balances': (_) => const AllBalancesScreen(),
      },
    );
  }
}
