import '../entities/transaction_entity.dart';

abstract class HistoryRepository {
  Future<List<TransactionEntity>> getTransactions({
    required String address,
    int count = 20,
  });
}
