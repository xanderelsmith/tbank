import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'blockchain_notification.dart';

class WebsocketNotificationHandler {
  final String nodeUrl;
  final String walletAddress;
  final StreamController<BlockchainNotification> controller;
  final VoidCallback onFallbackNeeded;

  WebSocket? _webSocket;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  bool _shouldReconnect = true;

  WebsocketNotificationHandler({
    required this.nodeUrl,
    required this.walletAddress,
    required this.controller,
    required this.onFallbackNeeded,
  });

  void start() {
    _shouldReconnect = true;
    _connectWebSocket();
  }

  void stop() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _webSocket?.close();
  }

  Future<void> _connectWebSocket() async {
    if (_webSocket != null || _isConnecting) return;
    _isConnecting = true;

    String wsUrl;
    if (nodeUrl.startsWith('https://')) {
      final host = Uri.parse(nodeUrl).host;
      wsUrl = 'wss://$host/ws';
    } else {
      final host = Uri.parse(nodeUrl).host;
      wsUrl = 'ws://$host/ws';
    }

    try {
      debugPrint(
        '[WebsocketNotificationHandler] Connecting to WebSocket: $wsUrl',
      );
      // Override connection to allow self-signed certs if necessary
      _webSocket = await WebSocket.connect(
        wsUrl,
      ).timeout(const Duration(seconds: 5));
      _isConnecting = false;
      debugPrint(
        '[WebsocketNotificationHandler] WebSocket connection established.',
      );

      // Subscriptions
      _subscribeToLogs();
      _subscribeToNewBlocks();

      _webSocket!.listen(
        (message) => _onMessageReceived(message),
        onError: (err) {
          debugPrint(
            '[WebsocketNotificationHandler] WebSocket stream error: $err',
          );
          _handleDisconnect();
        },
        onDone: () {
          debugPrint(
            '[WebsocketNotificationHandler] WebSocket stream closed by server.',
          );
          _handleDisconnect();
        },
      );
    } catch (e) {
      _isConnecting = false;
      debugPrint(
        '[WebsocketNotificationHandler] WebSocket connection failed: $e',
      );
      onFallbackNeeded();
    }
  }

  void _subscribeToLogs() {
    if (_webSocket == null) return;
    final cleanAddr = walletAddress.toLowerCase().replaceAll('0x', '');
    final paddedAddr = '0x${cleanAddr.padLeft(64, '0')}';

    // Subscribe to standard ERC-20 log Transfer events (topic[0] is Transfer signature, topic[2] is recipient)
    final payload = {
      "jsonrpc": "2.0",
      "id": 1,
      "method": "eth_subscribe",
      "params": [
        "logs",
        {
          "topics": [
            "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
            null,
            paddedAddr,
          ],
        },
      ],
    };
    _webSocket!.add(jsonEncode(payload));
    debugPrint('[WebsocketNotificationHandler] Subscribed to transfer logs.');
  }

  void _subscribeToNewBlocks() {
    if (_webSocket == null) return;
    final payload = {
      "jsonrpc": "2.0",
      "id": 2,
      "method": "eth_subscribe",
      "params": ["newHeads"],
    };
    _webSocket!.add(jsonEncode(payload));
    debugPrint('[WebsocketNotificationHandler] Subscribed to block headers.');
  }

  void _onMessageReceived(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);

      if (data.containsKey('result') && !data.containsKey('method')) {
        debugPrint(
          '[WebsocketNotificationHandler] Subscription confirmed: ${data['result']}',
        );
        return;
      }

      if (data['method'] == 'eth_subscription') {
        final params = data['params'];
        final result = params['result'];

        if (result != null && result is Map) {
          if (result.containsKey('topics')) {
            _processTransferLog(result.cast<String, dynamic>());
          } else if (result.containsKey('number')) {
            _processNewBlockHeader(result.cast<String, dynamic>());
          }
        }
      }
    } catch (e) {
      debugPrint('[WebsocketNotificationHandler] Parse error on message: $e');
    }
  }

  void _processTransferLog(Map<String, dynamic> log) {
    try {
      final topics = log['topics'] as List<dynamic>;
      if (topics.length < 3) return;

      // Decode recipient address from padded format
      final toPadded = topics[2].toString();
      final toAddress = '0x${toPadded.substring(toPadded.length - 40)}';

      // Verify recipient is the user
      if (toAddress.toLowerCase() == walletAddress.toLowerCase()) {
        final fromPadded = topics[1].toString();
        final fromAddress = '0x${fromPadded.substring(fromPadded.length - 40)}';

        final dataField = log['data'].toString();
        final valueHex = dataField.replaceAll('0x', '');
        final int value = int.tryParse(valueHex, radix: 16) ?? 0;
        final double amount = value / 1000000000000000000;

        controller.add(
          BlockchainNotification(
            title: 'Payment Received! 💰',
            body:
                'You received ${amount.toStringAsFixed(2)} tokens from $fromAddress',
            type: 'transfer',
            metadata: {
              'from': fromAddress,
              'amount': amount.toString(),
              'txHash': log['transactionHash'] ?? '',
            },
          ),
        );
      }
    } catch (e) {
      debugPrint(
        '[WebsocketNotificationHandler] Error decoding transfer log: $e',
      );
    }
  }

  void _processNewBlockHeader(Map<String, dynamic> blockHeader) {
    try {
      final blockHex = blockHeader['number'].toString().replaceAll('0x', '');
      final blockNum = int.tryParse(blockHex, radix: 16) ?? 0;

      controller.add(
        BlockchainNotification(
          title: 'New Block Mined ⛓️',
          body: 'Block #$blockNum has been confirmed on Toronet.',
          type: 'block',
          metadata: {'blockNumber': blockNum.toString()},
        ),
      );
    } catch (e) {
      debugPrint(
        '[WebsocketNotificationHandler] Error processing block header: $e',
      );
    }
  }

  void _handleDisconnect() {
    _webSocket = null;
    if (_shouldReconnect) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        debugPrint('[WebsocketNotificationHandler] Reconnecting WebSocket...');
        _connectWebSocket();
      });
    }
  }
}
