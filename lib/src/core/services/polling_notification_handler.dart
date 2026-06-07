import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'blockchain_notification.dart';

class PollingNotificationHandler {
  final String nodeUrl;
  final String walletAddress;
  final StreamController<BlockchainNotification> controller;

  Timer? _pollingTimer;
  String? _lastSeenTxHash;
  bool _isFirstPollLoad = true;

  PollingNotificationHandler({
    required this.nodeUrl,
    required this.walletAddress,
    required this.controller,
  });

  void start() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkForNewTransactions();
    });
    _checkForNewTransactions();
  }

  void stop() {
    _pollingTimer?.cancel();
  }

  Future<void> _checkForNewTransactions() async {
    try {
      final dio = Dio();
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );

      final response = await dio.get(
        '$nodeUrl/query',
        data: {
          'op': 'getaddrtransactions',
          'params': [
            {'name': 'addr', 'value': walletAddress},
            {'name': 'count', 'value': 2}, // Fetch recent few
          ],
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => true,
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> resData = response.data is String
            ? jsonDecode(response.data)
            : Map<String, dynamic>.from(response.data);

        if (resData['result'] == true) {
          final List<dynamic> txList = resData['data'] ?? [];

          if (txList.isNotEmpty) {
            final latestTx = txList.first;
            final txHash = latestTx['EV_Hash']?.toString() ?? '';
            final String? fromAddress = (latestTx['EV_From']);

            if (!_isFirstPollLoad && txHash != _lastSeenTxHash) {
              // Check if it is inbound transfer to active wallet
              if (fromAddress?.toString().toLowerCase() !=
                      walletAddress.toLowerCase() &&
                  latestTx['EV_To']?.toString().toLowerCase() ==
                      walletAddress.toLowerCase()) {
                final val =
                    latestTx['EV_Value']?.toString() ??
                    latestTx['EV_Value2']?.toString() ??
                    '0.00';

                final displayFrom =
                    (fromAddress == null ||
                        fromAddress.isEmpty ||
                        fromAddress == 'null')
                    ? 'System'
                    : fromAddress;

                controller.add(
                  BlockchainNotification(
                    title: 'Payment Received! 💰',
                    body: 'Received $val USD from $displayFrom',
                    type: 'transfer',
                    metadata: {
                      'from': displayFrom,
                      'amount': val,
                      'txHash': txHash,
                    },
                  ),
                );
              }
            }

            _lastSeenTxHash = txHash;
          }

          _isFirstPollLoad = false;
        }
      }
    } catch (e) {
      log('[PollingNotificationHandler] Polling fetch error: $e');
    }
  }
}
