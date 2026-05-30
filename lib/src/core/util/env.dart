import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:toronet/toronet.dart';

class Env {
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Fallback if .env is missing
    }
  }

  static Network get network {
    final envValue = dotenv.maybeGet('TORONET_NETWORK');
    if (envValue != null) {
      return envValue.toLowerCase() == 'mainnet' ? Network.mainnet : Network.testnet;
    }
    final value = String.fromEnvironment(
      'TORONET_NETWORK',
      defaultValue: 'testnet',
    );
    return value.toLowerCase() == 'mainnet' ? Network.mainnet : Network.testnet;
  }

  static String get adminAddress {
    return dotenv.maybeGet('TORONET_ADMIN_ADDRESS') ??
        '0x03c8ef05663bd8e4ad8074d650e4ccd33310cd95';
  }

  static String get adminPassword {
    return dotenv.maybeGet('TORONET_ADMIN_PASSWORD') ?? 'adminpwd';
  }
}
