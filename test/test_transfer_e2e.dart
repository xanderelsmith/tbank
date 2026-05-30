import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbank/src/core/services/toronet_client.dart';
import 'package:tbank/src/core/util/env.dart';
import 'package:tbank/src/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:tbank/src/features/transfer/data/repositories/transfer_repository_impl.dart';

String _generateRandomAddress() {
  final random = Random();
  final hexDigits = '0123456789abcdef';
  final buffer = StringBuffer('0x');
  for (int i = 0; i < 40; i++) {
    buffer.write(hexDigits[random.nextInt(16)]);
  }
  return buffer.toString();
}

void main() {
  test('E2E Transfer Test with Auto-Enrollment on Testnet', () async {
    await Env.init();
    final client = ToronetClient();
    final transferRepo = TransferRepositoryImpl(client);
    final paymentRepo = PaymentRepositoryImpl(client);
    final dio = Dio();

    // 1. Create a brand new wallet on the node using raw keystore endpoint
    final tempPassword = 'mysecretpassword';
    print('Creating temporary wallet for test via raw keystore API...');
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
    
    final fromAddress = createResponse.data['address']?.toString() ?? '';
    print('Temporary wallet created: $fromAddress');
    expect(fromAddress, isNotEmpty);

    // 2. Fund the temporary wallet with USD using the deposit faucet
    print('Funding temporary wallet with 100 USD...');
    final depositTx = await paymentRepo.initiateDeposit(
      amount: '100',
      currency: 'USD',
      address: fromAddress,
    );
    print('Funded temporary wallet with USD! Deposit Tx: $depositTx');

    // 3. Fund the temporary wallet with native ToroG Gas Token using the deposit faucet
    print('Funding temporary wallet with 10 ToroG...');
    final depositToroGTx = await paymentRepo.initiateDeposit(
      amount: '10',
      currency: 'ToroG',
      address: fromAddress,
    );
    print('Funded temporary wallet with ToroG! Deposit Tx: $depositToroGTx');

    // 4. Generate random recipient addresses for transfers
    final toAddressUSD = _generateRandomAddress();
    final toAddressToroG = _generateRandomAddress();

    // 5. Test USD Transfer
    print('Executing E2E transfer of USD from $fromAddress to $toAddressUSD...');
    try {
      final txHash = await transferRepo.transfer(
        fromAddress: fromAddress,
        toAddress: toAddressUSD,
        amount: '5',
        currency: 'USD',
        password: tempPassword,
      );

      print('USD Transfer SUCCEEDED! Transaction Hash: $txHash');
      expect(txHash, isNotEmpty);
    } catch (e) {
      print('USD Transfer FAILED: $e');
      fail('USD Transfer failed: $e');
    }

    // 6. Test ToroG Transfer
    print('Executing E2E transfer of ToroG from $fromAddress to $toAddressToroG...');
    try {
      final txHash = await transferRepo.transfer(
        fromAddress: fromAddress,
        toAddress: toAddressToroG,
        amount: '1',
        currency: 'ToroG',
        password: tempPassword,
      );

      print('ToroG Transfer SUCCEEDED! Transaction Hash: $txHash');
      expect(txHash, isNotEmpty);
    } catch (e) {
      print('ToroG Transfer FAILED: $e');
      fail('ToroG Transfer failed: $e');
    }

  }, timeout: const Timeout(Duration(minutes: 3)));
}
