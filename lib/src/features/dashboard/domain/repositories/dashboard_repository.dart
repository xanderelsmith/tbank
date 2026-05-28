import '../entities/token_balance.dart';

abstract class DashboardRepository {
  Future<List<TokenBalance>> getBalances({required String address});
}
