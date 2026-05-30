import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
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
      final dio = Dio();
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );

      final nodeUrl = _client.network == Network.testnet
          ? 'https://testnet.toronet.org/api'
          : 'https://api.toronet.org';

      final url = '$nodeUrl/query';
      final response = await dio.get(
        url,
        data: {
          'op': 'getaddrtransactions',
          'params': [
            {'name': 'addr', 'value': address},
            {'name': 'count', 'value': count * 5},
          ],
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => true,
        ),
      );

      if (response.statusCode != 200) {
        throw ServerFailure('Toronet node responded with status ${response.statusCode}');
      }

      final dynamic rawData = response.data;
      final Map<String, dynamic> responseMap;
      if (rawData is String) {
        responseMap = jsonDecode(rawData) as Map<String, dynamic>;
      } else if (rawData is Map) {
        responseMap = Map<String, dynamic>.from(rawData);
      } else {
        throw const ServerFailure('Invalid transaction response format');
      }

      if (responseMap['result'] == false) {
        throw ServerFailure(responseMap['error']?.toString() ?? 'Failed to query transactions');
      }

      final dynamic dataList = responseMap['data'];
      final List<dynamic> rawTxns;
      if (dataList is List) {
        rawTxns = dataList;
      } else {
        rawTxns = [];
      }

      final List<TransactionEntity> list = [];

      for (var tx in rawTxns) {
        if (tx is Map) {
          final from = tx['EV_From']?.toString() ?? '';
          final to = tx['EV_To']?.toString() ?? '';

          // Filter transactions for this user
          if (from.toLowerCase() == address.toLowerCase() ||
              to.toLowerCase() == address.toLowerCase()) {
            final type = from.toLowerCase() == address.toLowerCase()
                ? 'send'
                : 'receive';
            
            final amount = tx['EV_Value']?.toString() ?? tx['EV_Value2']?.toString() ?? '0.00';
            final hash = tx['EV_Hash']?.toString() ?? '';

            final contract = tx['EV_Contract']?.toString().toLowerCase() ?? '';
            String currencyName = 'USD';
            if (contract.contains('naira') || contract.contains('ngn')) {
              currencyName = 'NGN';
            } else if (contract.contains('dollar') || contract.contains('usd')) {
              currencyName = 'USD';
            } else if (contract.contains('toro')) {
              currencyName = 'TOROG';
            }

            // Safe parse date
            DateTime time = DateTime.now();
            final ts = tx['EV_Time'] ?? tx['EV_timestamp'] ?? tx['EV_time'];
            if (ts != null) {
              if (ts is int) {
                time = DateTime.fromMillisecondsSinceEpoch(
                  ts < 1000000000000 ? ts * 1000 : ts,
                );
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
                currency: currencyName,
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
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw ServerFailure(
        'Failed to fetch transactions: ${e.toString()}',
        statusCode: count,
      );
    }
  }
}
