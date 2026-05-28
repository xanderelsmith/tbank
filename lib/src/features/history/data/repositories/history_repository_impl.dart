import 'package:toronet/toronet.dart';
import '../../../../core/services/toronet_client.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final ToronetClient _client;

  HistoryRepositoryImpl(this._client);

  @override
  Future<List<TransactionEntity>> getTransactions({
    required String address,
    int count = 20,
  }) async {
    try {
      final List<dynamic> rawTxns = await _client.query.getTransactions(count: count * 5);
      
      final List<TransactionEntity> list = [];

      for (var tx in rawTxns) {
        if (tx is Map) {
          final from = tx['from']?.toString() ?? '';
          final to = tx['to']?.toString() ?? '';
          
          // Filter transactions for this user
          if (from.toLowerCase() == address.toLowerCase() || to.toLowerCase() == address.toLowerCase()) {
            final type = from.toLowerCase() == address.toLowerCase() ? 'send' : 'receive';
            final amount = tx['value']?.toString() ?? tx['amount']?.toString() ?? '0.00';
            final hash = tx['hash']?.toString() ?? tx['txHash']?.toString() ?? '';
            
            // Safe parse date
            DateTime time = DateTime.now();
            final ts = tx['timestamp'] ?? tx['time'];
            if (ts != null) {
              if (ts is int) {
                // Check if unix timestamp is in seconds or milliseconds
                time = DateTime.fromMillisecondsSinceEpoch(ts < 1000000000000 ? ts * 1000 : ts);
              } else if (ts is String) {
                time = DateTime.tryParse(ts) ?? DateTime.now();
              }
            }

            list.add(
              TransactionEntity(
                txHash: hash,
                fromAddress: from,
                toAddress: to,
                amount: amount,
                currency: tx['currency']?.toString() ?? 'USD',
                type: type,
                timestamp: time,
                status: 'completed',
              ),
            );
          }
        }
      }

      // Sort by timestamp desc
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Limit results
      return list.take(count).toList();
    } on APIException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to fetch transactions: $e');
    }
  }
}
