import 'dart:async';
import 'package:flutter/foundation.dart';
import 'blockchain_notification.dart';
import 'websocket_notification_handler.dart';
import 'polling_notification_handler.dart';

export 'blockchain_notification.dart';

class NotificationService {
  final String _nodeUrl;
  final String _walletAddress;

  bool _usePollingFallback = false;

  final _controller = StreamController<BlockchainNotification>.broadcast();
  Stream<BlockchainNotification> get stream => _controller.stream;

  WebsocketNotificationHandler? _websocketHandler;
  PollingNotificationHandler? _pollingHandler;

  NotificationService({required String nodeUrl, required String walletAddress})
    : _nodeUrl = nodeUrl.replaceAll(RegExp(r'/$'), ''), // Strip trailing slash
      _walletAddress = walletAddress {
    _websocketHandler = WebsocketNotificationHandler(
      nodeUrl: _nodeUrl,
      walletAddress: _walletAddress,
      controller: _controller,
      onFallbackNeeded: _switchToPolling,
    );

    _pollingHandler = PollingNotificationHandler(
      nodeUrl: _nodeUrl,
      walletAddress: _walletAddress,
      controller: _controller,
    );
  }

  /// Start the notification listener
  void start() {
    _usePollingFallback = false;
    _websocketHandler?.start();
  }

  /// Stop the listener and clean up resources
  void stop() {
    debugPrint('[NotificationService] Stopping service...');
    _websocketHandler?.stop();
    _pollingHandler?.stop();
  }

  void _switchToPolling() {
    if (_usePollingFallback) return;
    _usePollingFallback = true;

    debugPrint('[NotificationService] Switching to HTTP Polling fallback...');
    _websocketHandler?.stop();
    _pollingHandler?.start();
  }
}
