import 'package:toronet/toronet.dart';
import 'package:toronet/src/payments/payments.dart' as pay;
import '../../../../core/services/toronet_client.dart';
import '../../../../core/util/env.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/bank_entity.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final ToronetClient _client;

  PaymentRepositoryImpl(this._client);

  @override
  Future<String> initiateDeposit({
    required String amount,
    required String currency,
    required String address,
  }) async {
    try {
      // Map to correct Currency enum. PaymentsService might use NGN or naira.
      // Based on our analysis, we use Currency.naira for NGN and Currency.dollar for USD.
      final currencyEnum = currency.toUpperCase() == 'USD' ? pay.Currency.USD : pay.Currency.NGN;

      final depositResult = await _client.payments.depositFunds(
        userAddress: address,
        username: 'tbank_user',
        amount: amount,
        currency: currencyEnum,
        admin: Env.adminAddress,
        adminpwd: Env.adminPassword,
      );

      // The result is usually a payment URL or payment reference ID
      return depositResult['result']?.toString() ?? depositResult['txid']?.toString() ?? depositResult.toString();
    } on ValidationException catch (e) {
      throw ValidationFailure(e.message);
    } on APIException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Deposit initiation failed: $e');
    }
  }

  @override
  Future<bool> confirmDeposit({
    required String paymentId,
    required String amount,
  }) async {
    try {
      final confirmResult = await _client.payments.confirmDeposit(
        currency: 'NGN',
        txid: paymentId,
        paymentType: 'bank',
        admin: Env.adminAddress,
        adminpwd: Env.adminPassword,
      );

      // Returns true if verification succeeded
      return confirmResult['result'] == true ||
          confirmResult['result']?.toString().toLowerCase().contains('success') == true ||
          confirmResult.toString().toLowerCase().contains('success');
    } catch (e) {
      throw ServerFailure('Confirmation failed: $e');
    }
  }

  @override
  Future<List<BankEntity>> getBanks({required String currency}) async {
    try {
      if (currency.toUpperCase() == 'USD') {
        final usdList = await _client.payments.getBankListUSD();
        return usdList.map((b) => BankEntity(code: b['code']?.toString() ?? '', name: b['name']?.toString() ?? '')).toList();
      } else {
        final ngnList = await _client.payments.getBankListNGN();
        // The list contains Map items with keys like 'code' and 'name'
        return ngnList.map((b) => BankEntity(
          code: b['code']?.toString() ?? b['bankCode']?.toString() ?? '',
          name: b['name']?.toString() ?? b['bankName']?.toString() ?? '',
        )).toList();
      }
    } catch (e) {
      throw ServerFailure('Failed to load bank list: $e');
    }
  }

  @override
  Future<String> verifyBankAccount({
    required String bankCode,
    required String accountNumber,
  }) async {
    try {
      final response = await _client.payments.verifyBankAccountNameNGN(
        destinationInstitutionCode: bankCode,
        accountNumber: accountNumber,
        admin: Env.adminAddress,
        adminpwd: Env.adminPassword,
      );
      final accountName = response['result']?['accountName']?.toString() ??
          response['result']?.toString() ??
          response['accountName']?.toString() ??
          response['accountname']?.toString() ?? '';
      if (accountName.isEmpty) {
        throw const ValidationFailure('Could not verify account name. Please check account details.');
      }
      return accountName;
    } catch (e) {
      throw ServerFailure('Bank account verification failed: $e');
    }
  }

  @override
  Future<String> withdraw({
    required String address,
    required String amount,
    required String currency,
    required String bankCode,
    required String accountNumber,
    required String accountName,
    required String password,
  }) async {
    try {
      final response = await _client.payments.recordFiatWithdrawal(
        address: address,
        password: password,
        currency: currency.toUpperCase(),
        token: 'toro',
        payername: accountName,
        payeremail: 'user@tbank.com',
        payeraddress: '123 Payer St',
        payercity: 'Lagos',
        payerstate: 'Lagos',
        payercountry: 'Nigeria',
        payerzipcode: '100001',
        payerphone: '08012345678',
        description: 'ToroBank Payout',
        amount: amount,
        accounttype: 'savings',
        bankname: 'Destination Bank',
        routingno: bankCode,
        accountno: accountNumber,
        accountname: accountName,
        recipientstate: 'Lagos',
        recipientzip: '100001',
        recipientphone: '08012345678',
        admin: Env.adminAddress,
        adminpwd: Env.adminPassword,
      );
      final txHash = response['result']?.toString() ?? response['txhash']?.toString() ?? response['txId']?.toString() ?? '';
      return txHash;
    } on ValidationException catch (e) {
      throw ValidationFailure(e.message);
    } catch (e) {
      throw ServerFailure('Withdrawal failed: $e');
    }
  }
}
