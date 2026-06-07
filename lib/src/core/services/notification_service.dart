import 'dart:async';
import 'package:flutter/foundation.dart';
import 'blockchain_notification.dart';
import 'polling_notification_handler.dart';

export 'blockchain_notification.dart';

class NotificationService {
  final String _nodeUrl;
  final String _walletAddress;

  final _controller = StreamController<BlockchainNotification>.broadcast();
  Stream<BlockchainNotification> get stream => _controller.stream;

  PollingNotificationHandler? _pollingHandler;

  NotificationService({required String nodeUrl, required String walletAddress})
    : _nodeUrl = nodeUrl.replaceAll(RegExp(r'/$'), ''), // Strip trailing slash
      _walletAddress = walletAddress {
    _pollingHandler = PollingNotificationHandler(
      nodeUrl: _nodeUrl,
      walletAddress: _walletAddress,
      controller: _controller,
    );
  }

  /// Start the notification listener
  void start() {
    debugPrint(
      '[NotificationService] Starting HTTP Polling for notifications...',
    );
    _pollingHandler?.start();
  }

  /// Stop the listener and clean up resources
  void stop() {
    debugPrint('[NotificationService] Stopping service...');
    _pollingHandler?.stop();
  }
}
