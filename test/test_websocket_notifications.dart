import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbank/src/core/services/toronet_client.dart';
import 'package:tbank/src/core/services/notification_service.dart';
import 'package:tbank/src/core/util/env.dart';
import 'package:tbank/src/features/payment/data/repositories/payment_repository_impl.dart';

void main() {
  test('WebSocket & Polling Notification Service E2E Test', () async {
    await Env.init();
    final client = ToronetClient();
    final paymentRepo = PaymentRepositoryImpl(client);
    final dio = Dio();

    // 1. Create a temporary wallet on the node
    final tempPassword = 'testnotifpassword';
    print('Creating temporary wallet for notification test via keystore API...');
    final createResponse = await dio.post(
      'https://testnet.toronet.org/api/keystore',
      data: {
        'op': 'createkey',
        'params': [
          {'name': 'pwd', 'value': tempPassword},
        ],
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    
    final walletAddress = createResponse.data['address']?.toString() ?? '';
    print('Wallet created: $walletAddress');
    expect(walletAddress, isNotEmpty);

    // 2. Initialize NotificationService
    print('Initializing NotificationService...');
    final service = NotificationService(
      nodeUrl: client.nodeUrl,
      walletAddress: walletAddress,
    );

    List<BlockchainNotification> receivedNotifications = [];
    final completer = Completer<void>();

    final subscription = service.stream.listen((notification) {
      print('>>> NOTIFICATION RECEIVED: [${notification.type}] ${notification.title} - ${notification.body}');
      receivedNotifications.add(notification);
      
      // Complete as soon as we get either a block or transfer notification
      if (!completer.isCompleted) completer.complete();
    });

    service.start();

    // 3. Wait 2 seconds for WS / polling handshake to initialize
    await Future.delayed(const Duration(seconds: 2));

    // 4. Fund the wallet (triggering an on-chain event)
    print('Initiating deposit (funding) of 10 USD to trigger logs...');
    final depositTx = await paymentRepo.initiateDeposit(
      amount: '10',
      currency: 'USD',
      address: walletAddress,
    );
    print('Funded temporary wallet! Tx: $depositTx');

    // 5. Wait for the notification (max 45 seconds to account for block time / polling interval)
    print('Waiting for notification event...');
    try {
      await completer.future.timeout(const Duration(seconds: 45));
    } on TimeoutException {
      print('Timeout waiting for transfer notification.');
    }

    // 6. Clean up
    print('Stopping notification service...');
    await subscription.cancel();
    service.stop();

    // 7. Verification assertions
    print('Verifying notifications received...');
    expect(receivedNotifications, isNotEmpty);
    
    final hasTransfer = receivedNotifications.any((n) => n.type == 'transfer');
    final hasBlock = receivedNotifications.any((n) => n.type == 'block');
    print('Received Transfer notification: $hasTransfer');
    print('Received Block notification: $hasBlock');
    
    expect(hasTransfer || hasBlock, isTrue, reason: 'Should receive at least one type of notification event.');

  }, timeout: const Timeout(Duration(minutes: 2)));
}
