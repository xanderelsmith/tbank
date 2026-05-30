import 'package:flutter_test/flutter_test.dart';
import 'package:tbank/src/core/services/toronet_client.dart';
import 'package:tbank/src/core/util/env.dart';
import 'package:tbank/src/features/payment/data/repositories/payment_repository_impl.dart';

void main() {
  test('Test PaymentRepositoryImpl initiateDeposit on testnet (USD and ToroG)', () async {
    await Env.init();
    final client = ToronetClient();
    final repo = PaymentRepositoryImpl(client);
    final testAddress = '0x5d4f2ceed2fab22480627817ad8a1abd72507c58';

    // Test USD Stablecoin Faucet
    try {
      print('Testing USD deposit faucet...');
      final txHash = await repo.initiateDeposit(
        amount: '100',
        currency: 'USD',
        address: testAddress,
      );
      print('USD Deposit success! Tx Hash: $txHash');
      expect(txHash, isNotEmpty);
    } catch (e) {
      print('USD Deposit failed: $e');
      fail('USD Deposit failed: $e');
    }

    // Test ToroG Gas Token Faucet
    try {
      print('Testing ToroG gas token deposit faucet...');
      final txHash = await repo.initiateDeposit(
        amount: '10',
        currency: 'ToroG',
        address: testAddress,
      );
      print('ToroG Deposit success! Tx Hash: $txHash');
      expect(txHash, isNotEmpty);
    } catch (e) {
      print('ToroG Deposit failed: $e');
      fail('ToroG Deposit failed: $e');
    }
  });
}
