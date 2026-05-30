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
      // Query multi-currency balances in parallel
      // Toro Gas Token (ToroG) is the native blockchain token and must be queried via getBalance
      final futures = [
        _client.currency.getCurrencyBalance(
          currency: Currency.dollar,
          address: address,
        ),
        _client.currency.getCurrencyBalance(
          currency: Currency.naira,
          address: address,
        ),
        _client.balance.getBalance(address: address),
      ];

      final results = await Future.wait(futures);

      return [
        TokenBalance(
          symbol: 'USD',
          name: 'Toro Dollar',
          amount:
              results[0]['balance']?.toString() ??
              results[0]['result']?.toString() ??
              '0.00',
        ),
        TokenBalance(
          symbol: 'NGN',
          name: 'Toro Naira',
          amount:
              results[1]['balance']?.toString() ??
              results[1]['result']?.toString() ??
              '0.00',
        ),
        TokenBalance(
          symbol: 'ToroG',
          name: 'Toro Gas Token',
          amount:
              results[2]['bal_toro']?.toString() ??
              results[2]['balance']?.toString() ??
              '0.00',
        ),
      ];
    } on APIException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on ToroSDKException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to fetch balances: $e');
    }
  }
}
