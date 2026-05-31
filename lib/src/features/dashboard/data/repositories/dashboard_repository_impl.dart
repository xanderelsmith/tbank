import 'package:toronet/toronet.dart';
import '../../../../core/services/toronet_client.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/token_balance.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final ToronetClient _client;

  DashboardRepositoryImpl(this._client);

  @override
  Future<List<TokenBalance>> getBalances({required String address}) async {
    try {
      // The getBalance endpoint returns all asset balances in a single JSON payload
      // e.g. {bal_toro: 150, bal_dollar: 14400, bal_naira: 1954000, ...}
      final result = await _client.balance.getBalance(address: address);

      final List<TokenBalance> balances = [];

      // Ordered list of supported currencies to map from the API response
      final currencyMap = {
        'bal_toro': {'symbol': 'ToroG', 'name': 'Toro Gas Token'},
        'bal_dollar': {'symbol': 'USD', 'name': 'Toro Dollar'},
        'bal_naira': {'symbol': 'NGN', 'name': 'Toro Naira'},
        'bal_euro': {'symbol': 'EUR', 'name': 'Toro Euro'},
        'bal_pound': {'symbol': 'GBP', 'name': 'Toro Pound'},
        'bal_egp': {'symbol': 'EGP', 'name': 'Toro EGP'},
        'bal_ksh': {'symbol': 'KSH', 'name': 'Toro KSH'},
        'bal_zar': {'symbol': 'ZAR', 'name': 'Toro ZAR'},
        'bal_eth': {'symbol': 'ETH', 'name': 'Ethereum'},
        'bal_espees': {'symbol': 'ESPEES', 'name': 'Toro Espees'},
        'bal_plast': {'symbol': 'PLAST', 'name': 'Toro Plast'},
      };

      for (var entry in currencyMap.entries) {
        final key = entry.key;
        final info = entry.value;
        if (result.containsKey(key)) {
          balances.add(TokenBalance(
            symbol: info['symbol']!,
            name: info['name']!,
            amount: result[key]?.toString() ?? '0',
          ));
        }
      }

      return balances;
    } on APIException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on ToroSDKException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to fetch balances: $e');
    }
  }
}
