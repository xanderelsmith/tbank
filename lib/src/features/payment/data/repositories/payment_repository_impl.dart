import 'dart:developer' as developer;
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:toronet/toronet.dart';
import 'package:toronet/src/payments/payments.dart' as pay;
import '../../../../core/services/toronet_client.dart';
import '../../../../core/services/apiurl.dart';
import '../../../../core/util/env.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/bank_entity.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final ToronetClient _client;

  PaymentRepositoryImpl(this._client);

  @override
  bool get isTestnet => _client.network == Network.testnet;

  @override
  Future<String> initiateDeposit({
    required String amount,
    required String currency,
    required String address,
  }) async {
    developer.log(
      'initiateDeposit called: address=$address, amount=$amount, currency=$currency, network=${_client.network}',
      name: 'PaymentRepository',
    );

    try {
      // If we are on testnet, simulate the fiat deposit by executing a real on-chain mint/import currency
      // using the testnet owner credentials. This allows instant funding during demos.
      if (_client.network == Network.testnet) {
        final String url;
        final String operation;
        final Map<String, dynamic> requestData;

        String mappedCurrency;
        bool isToken = false;
        switch (currency.toUpperCase()) {
          case 'USD':
          case 'USDC':
            mappedCurrency = 'dollar';
            break;
          case 'NGN':
            mappedCurrency = 'naira';
            break;
          case 'EUR':
            mappedCurrency = 'euro';
            break;
          case 'GBP':
            mappedCurrency = 'pound';
            break;
          case 'EGP':
            mappedCurrency = 'egp';
            break;
          case 'KSH':
            mappedCurrency = 'ksh';
            break;
          case 'ZAR':
            mappedCurrency = 'zar';
            break;
          case 'ETH':
            mappedCurrency = 'eth';
            isToken = true;
            break;
          case 'ESPEES':
            mappedCurrency = 'espees';
            isToken = true;
            break;
          case 'PLAST':
            mappedCurrency = 'plast';
            isToken = true;
            break;
          case 'TOROG':
          case 'TORO':
            mappedCurrency = 'toro';
            isToken = true;
            break;
          default:
            mappedCurrency = 'naira'; // fallback
        }

        if (isToken) {
          url = '${ApiUrl.testbaseUrl}/token/$mappedCurrency/ad';
          operation = 'mint';
        } else {
          url = '${ApiUrl.testbaseUrl}/currency/$mappedCurrency/ad';
          operation = 'importcurrency';
        }

        requestData = {
          'op': operation,
          'params': [
            {
              'name': 'admin',
              'value': Env.testnetSuperAdminAddress,
            },
            {'name': 'adminpwd', 'value': Env.testnetSuperAdminPassword},
            {'name': 'addr', 'value': address},
            {'name': 'val', 'value': amount},
          ],
        };

        developer.log(
          'Testnet detected: Minting $amount $currency instantly to $address...',
          name: 'PaymentRepository',
        );

        final dio = Dio();
        dio.httpClientAdapter = IOHttpClientAdapter(
          createHttpClient: () {
            final client = HttpClient();
            client.badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;
            return client;
          },
        );

        final response = await dio.post(
          url,
          data: requestData,
          options: Options(
            headers: {'Content-Type': 'application/json'},
            validateStatus: (status) => true,
          ),
        );

        developer.log(
          'Testnet mint response status: ${response.statusCode}, body: ${response.data}',
          name: 'PaymentRepository',
        );

        if (response.statusCode == 200) {
          final dynamic rawData = response.data;
          final Map<String, dynamic> responseMap;
          if (rawData is String) {
            responseMap = jsonDecode(rawData) as Map<String, dynamic>;
          } else if (rawData is Map) {
            responseMap = Map<String, dynamic>.from(rawData);
          } else {
            throw const ServerFailure(
              'Invalid response structure from testnet node',
            );
          }

          if (responseMap['result'] == true) {
            final txHash =
                responseMap['transaction']?.toString() ?? 'tx_testnet_success';
            developer.log(
              'Testnet mint success: txHash=$txHash',
              name: 'PaymentRepository',
            );
            return txHash;
          } else {
            final err =
                responseMap['error']?.toString() ??
                'Failed to import stablecoin on testnet';
            developer.log(
              'Testnet mint failed: $err',
              name: 'PaymentRepository',
            );
            throw ServerFailure(err);
          }
        } else {
          throw ServerFailure(
            'Testnet node responded with HTTP status ${response.statusCode}',
          );
        }
      }

      // Mainnet/Live logic using ConnectW SDK
      final currencyEnum = currency.toUpperCase() == 'USD'
          ? pay.Currency.USD
          : pay.Currency.NGN;

      final depositResult = await _client.payments.depositFunds(
        userAddress: address,
        username: 'tbank_user',
        amount: amount,
        currency: currencyEnum,
        admin: Env.adminAddress,
        adminpwd: Env.adminPassword,
      );

      developer.log(
        'initiateDeposit success: result=$depositResult',
        name: 'PaymentRepository',
      );
      return depositResult['result']?.toString() ??
          depositResult['txid']?.toString() ??
          depositResult.toString();
    } on ValidationException catch (e) {
      developer.log(
        'initiateDeposit validation exception: ${e.message}',
        name: 'PaymentRepository',
        error: e,
      );
      throw ValidationFailure(e.message);
    } on APIException catch (e) {
      developer.log(
        'initiateDeposit API exception: ${e.message}',
        name: 'PaymentRepository',
        error: e,
      );
      throw ServerFailure(e.message);
    } catch (e) {
      developer.log(
        'initiateDeposit error: $e',
        name: 'PaymentRepository',
        error: e,
      );
      throw ServerFailure('Deposit initiation failed: $e');
    }
  }

  @override
  Future<bool> confirmDeposit({
    required String paymentId,
    required String amount,
  }) async {
    developer.log(
      'confirmDeposit called: paymentId=$paymentId, amount=$amount, network=${_client.network}',
      name: 'PaymentRepository',
    );

    try {
      if (_client.network == Network.testnet) {
        developer.log(
          'Testnet detected: Instantly confirming deposit ($paymentId)',
          name: 'PaymentRepository',
        );
        return true;
      }

      final confirmResult = await _client.payments.confirmDeposit(
        currency: 'NGN',
        txid: paymentId,
        paymentType: 'bank',
        admin: Env.adminAddress,
        adminpwd: Env.adminPassword,
      );

      developer.log(
        'confirmDeposit response: $confirmResult',
        name: 'PaymentRepository',
      );

      final isSuccess =
          confirmResult['result'] == true ||
          confirmResult['result']?.toString().toLowerCase().contains(
                'success',
              ) ==
              true ||
          confirmResult.toString().toLowerCase().contains('success');

      developer.log(
        'confirmDeposit success: $isSuccess',
        name: 'PaymentRepository',
      );
      return isSuccess;
    } catch (e) {
      developer.log(
        'confirmDeposit error: $e',
        name: 'PaymentRepository',
        error: e,
      );
      throw ServerFailure('Confirmation failed: $e');
    }
  }

  @override
  Future<List<BankEntity>> getBanks({required String currency}) async {
    developer.log(
      'getBanks called: currency=$currency',
      name: 'PaymentRepository',
    );
    try {
      if (currency.toUpperCase() == 'USD') {
        final usdList = await _client.payments.getBankListUSD();
        developer.log(
          'getBanks success: loaded ${usdList.length} USD banks',
          name: 'PaymentRepository',
        );
        return usdList
            .map(
              (b) => BankEntity(
                code: b['code']?.toString() ?? '',
                name: b['name']?.toString() ?? '',
              ),
            )
            .toList();
      } else {
        final ngnList = await _client.payments.getBankListNGN();
        developer.log(
          'getBanks success: loaded ${ngnList.length} NGN banks',
          name: 'PaymentRepository',
        );
        return ngnList
            .map(
              (b) => BankEntity(
                code: b['code']?.toString() ?? b['bankCode']?.toString() ?? '',
                name: b['name']?.toString() ?? b['bankName']?.toString() ?? '',
              ),
            )
            .toList();
      }
    } catch (e) {
      developer.log('getBanks error: $e', name: 'PaymentRepository', error: e);
      throw ServerFailure('Failed to load bank list: $e');
    }
  }

  @override
  Future<String> verifyBankAccount({
    required String bankCode,
    required String accountNumber,
  }) async {
    developer.log(
      'verifyBankAccount called: bankCode=$bankCode, accountNumber=$accountNumber',
      name: 'PaymentRepository',
    );
    try {
      final response = await _client.payments.verifyBankAccountNameNGN(
        destinationInstitutionCode: bankCode,
        accountNumber: accountNumber,
        admin: Env.adminAddress,
        adminpwd: Env.adminPassword,
      );
      final accountName =
          response['result']?['accountName']?.toString() ??
          response['result']?.toString() ??
          response['accountName']?.toString() ??
          response['accountname']?.toString() ??
          '';
      developer.log(
        'verifyBankAccount success: accountName=$accountName',
        name: 'PaymentRepository',
      );
      if (accountName.isEmpty) {
        throw const ValidationFailure(
          'Could not verify account name. Please check account details.',
        );
      }
      return accountName;
    } catch (e) {
      developer.log(
        'verifyBankAccount error: $e',
        name: 'PaymentRepository',
        error: e,
      );
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
    developer.log(
      'withdraw called: address=$address, amount=$amount, currency=$currency, bankCode=$bankCode, accountNumber=$accountNumber, accountName=$accountName',
      name: 'PaymentRepository',
    );
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
      final txHash =
          response['result']?.toString() ??
          response['txhash']?.toString() ??
          response['txId']?.toString() ??
          '';
      developer.log(
        'withdraw success: txHash=$txHash',
        name: 'PaymentRepository',
      );
      return txHash;
    } on ValidationException catch (e) {
      developer.log(
        'withdraw validation error: ${e.message}',
        name: 'PaymentRepository',
        error: e,
      );
      throw ValidationFailure(e.message);
    } catch (e) {
      developer.log('withdraw error: $e', name: 'PaymentRepository', error: e);
      throw ServerFailure('Withdrawal failed: $e');
    }
  }
}
