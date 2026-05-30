import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class BlockchainNotification {
  final String title;
  final String body;
  final String type; // 'transfer', 'block', etc.
  final Map<String, dynamic> metadata;

  BlockchainNotification({
    required this.title,
    required this.body,
    required this.type,
    this.metadata = const {},
  });
}

class NotificationService {
  final String _nodeUrl; // e.g. 'https://testnet.toronet.org/api'
  final String _walletAddress;
  
  WebSocket? _webSocket;
  Timer? _reconnectTimer;
  Timer? _pollingTimer;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  bool _usePollingFallback = false;
  
  // Track last seen transaction for polling fallback
  String? _lastSeenTxHash;
  bool _isFirstPollLoad = true;

  final _controller = StreamController<BlockchainNotification>.broadcast();
  
  Stream<BlockchainNotification> get stream => _controller.stream;

  NotificationService({
    required String nodeUrl,
    required String walletAddress,
  })  : _nodeUrl = nodeUrl.replaceAll(RegExp(r'/$'), ''), // Strip trailing slash
        _walletAddress = walletAddress;

  /// Start the notification listener
  void start() {
    _shouldReconnect = true;
    _usePollingFallback = false;
    _connectWebSocket();
  }

  /// Stop the listener and clean up resources
  void stop() {
    debugPrint('[NotificationService] Stopping service...');
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _pollingTimer?.cancel();
    _webSocket?.close();
  }

  /// Connect to the node's JSON-RPC WebSocket
  Future<void> _connectWebSocket() async {
    if (_webSocket != null || _isConnecting || _usePollingFallback) return;
    _isConnecting = true;

    // Derived WebSocket URL from node URL
    // e.g. https://testnet.toronet.org/api -> wss://testnet.toronet.org/ws
    // Or we try standard wss mapping.
    String wsUrl;
    if (_nodeUrl.startsWith('https://')) {
      final host = Uri.parse(_nodeUrl).host;
      wsUrl = 'wss://$host/ws';
    } else {
      final host = Uri.parse(_nodeUrl).host;
      wsUrl = 'ws://$host/ws';
    }

    try {
      debugPrint('[NotificationService] Connecting to WebSocket: $wsUrl');
      // Override connection to allow self-signed certs if necessary
      _webSocket = await WebSocket.connect(wsUrl).timeout(const Duration(seconds: 5));
      _isConnecting = false;
      debugPrint('[NotificationService] WebSocket connection established.');

      // Subscriptions
      _subscribeToLogs();
      _subscribeToNewBlocks();

      _webSocket!.listen(
        (message) => _onMessageReceived(message),
        onError: (err) {
          debugPrint('[NotificationService] WebSocket stream error: $err');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('[NotificationService] WebSocket stream closed by server.');
          _handleDisconnect();
        },
      );
    } catch (e) {
      _isConnecting = false;
      debugPrint('[NotificationService] WebSocket connection failed: $e');
      
      // If first attempt fails, switch to fallback polling
      _usePollingFallback = true;
      debugPrint('[NotificationService] Switching to HTTP Polling fallback...');
      _startPolling();
    }
  }

  void _subscribeToLogs() {
    if (_webSocket == null) return;
    final cleanAddr = _walletAddress.toLowerCase().replaceAll('0x', '');
    final paddedAddr = '0x' + cleanAddr.padLeft(64, '0');

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
            paddedAddr
          ]
        }
      ]
    };
    _webSocket!.add(jsonEncode(payload));
    debugPrint('[NotificationService] Subscribed to transfer logs.');
  }

  void _subscribeToNewBlocks() {
    if (_webSocket == null) return;
    final payload = {
      "jsonrpc": "2.0",
      "id": 2,
      "method": "eth_subscribe",
      "params": ["newHeads"]
    };
    _webSocket!.add(jsonEncode(payload));
    debugPrint('[NotificationService] Subscribed to block headers.');
  }

  void _onMessageReceived(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      
      if (data.containsKey('result') && !data.containsKey('method')) {
        debugPrint('[NotificationService] Subscription confirmed: ${data['result']}');
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
      debugPrint('[NotificationService] Parse error on message: $e');
    }
  }

  void _processTransferLog(Map<String, dynamic> log) {
    try {
      final topics = log['topics'] as List<dynamic>;
      if (topics.length < 3) return;

      // Decode recipient address from padded format
      final toPadded = topics[2].toString();
      final toAddress = '0x' + toPadded.substring(toPadded.length - 40);

      // Verify recipient is the user
      if (toAddress.toLowerCase() == _walletAddress.toLowerCase()) {
        final fromPadded = topics[1].toString();
        final fromAddress = '0x' + fromPadded.substring(fromPadded.length - 40);

        final dataField = log['data'].toString();
        final valueHex = dataField.replaceAll('0x', '');
        final int value = int.tryParse(valueHex, radix: 16) ?? 0;
        final double amount = value / 1000000000000000000;

        _controller.add(
          BlockchainNotification(
            title: 'Payment Received! 💰',
            body: 'You received ${amount.toStringAsFixed(2)} tokens from $fromAddress',
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
      debugPrint('[NotificationService] Error decoding transfer log: $e');
    }
  }

  void _processNewBlockHeader(Map<String, dynamic> blockHeader) {
    try {
      final blockHex = blockHeader['number'].toString().replaceAll('0x', '');
      final blockNum = int.tryParse(blockHex, radix: 16) ?? 0;

      _controller.add(
        BlockchainNotification(
          title: 'New Block Mined ⛓️',
          body: 'Block #$blockNum has been confirmed on Toronet.',
          type: 'block',
          metadata: {'blockNumber': blockNum.toString()},
        ),
      );
    } catch (e) {
      debugPrint('[NotificationService] Error processing block header: $e');
    }
  }

  void _handleDisconnect() {
    _webSocket = null;
    if (_shouldReconnect) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        debugPrint('[NotificationService] Reconnecting WebSocket...');
        _connectWebSocket();
      });
    }
  }

  // --- HTTP Polling Fallback Implementation ---

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkForNewTransactions();
    });
    _checkForNewTransactions();
  }

  Future<void> _checkForNewTransactions() async {
    try {
      final dio = Dio();
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );

      final response = await dio.get(
        '$_nodeUrl/query',
        data: {
          'op': 'getaddrtransactions',
          'params': [
            {'name': 'addr', 'value': _walletAddress},
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
            final fromAddress = latestTx['EV_From']?.toString() ?? '';

            if (!_isFirstPollLoad && txHash != _lastSeenTxHash) {
              // Check if it is inbound transfer to active wallet
              if (fromAddress.toLowerCase() != _walletAddress.toLowerCase() && 
                  latestTx['EV_To']?.toString().toLowerCase() == _walletAddress.toLowerCase()) {
                final val = latestTx['EV_Value']?.toString() ?? latestTx['EV_Value2']?.toString() ?? '0.00';
                
                _controller.add(
                  BlockchainNotification(
                    title: 'Payment Received! 💰',
                    body: 'Received $val USD from $fromAddress',
                    type: 'transfer',
                    metadata: {
                      'from': fromAddress,
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
      debugPrint('[NotificationService] Polling fetch error: $e');
    }
  }
}
