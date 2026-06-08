import 'dart:developer' as developer;
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:toronet/toronet.dart';
import '../../../../core/services/toronet_client.dart';
import '../../../../core/util/env.dart';
import '../../../../core/services/apiurl.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/transfer_repository.dart';

class TransferRepositoryImpl implements TransferRepository {
  final ToronetClient _client;

  TransferRepositoryImpl(this._client);

  ///
  @override
  Future<String> resolveTNS(String username) async {
    try {
      // Clean up username (TNS name should not have spaces or @ symbols)
      final cleanUsername = username.replaceAll('@', '').trim();

      final response = await _client.tns.getAddress(name: cleanUsername);
      final address =
          response['address']?.toString() ??
          response['addr']?.toString() ??
          (response['result'] is String ? response['result'].toString() : '');
      if (address.isEmpty ||
          address == '0x0000000000000000000000000000000000000000') {
        throw const ValidationFailure('TNS username resolved to empty address');
      }
      return address;
    } on ValidationException catch (e) {
      throw ValidationFailure(e.message);
    } catch (e) {
      throw ServerFailure('Could not resolve TNS username: $e');
    }
  }

  @override
  Future<String> transfer({
    required String fromAddress,
    required String toAddress,
    required String amount,
    required String currency,
    required String password,
  }) async {
    try {
      final Currency currencyEnum;
      switch (currency.toUpperCase()) {
        case 'USD':
          currencyEnum = Currency.dollar;
          break;
        case 'NGN':
          currencyEnum = Currency.naira;
          break;
        case 'TOROG':
        case 'TORO':
          currencyEnum = Currency.toro;
          break;
        default:
          currencyEnum = Currency.dollar;
      }

      final String currencyStr = currencyEnum.name;

      final dio = Dio();
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );

      final nodeUrl = _client.getNetwork == Network.testnet
          ? ApiUrl.testbaseUrl
          : ApiUrl.mainnetBaseUrl;

      if (_client.getNetwork == Network.testnet) {
        // Auto-enroll both sender and recipient addresses on testnet
        await _ensureEnrolled(dio, nodeUrl, currencyStr, fromAddress);
        await _ensureEnrolled(dio, nodeUrl, currencyStr, toAddress);
      }

      final pathPrefix = (currencyStr == 'toro') ? 'token' : 'currency';
      final url = '$nodeUrl/$pathPrefix/$currencyStr/cl';

      final String clientAddress;
      final String clientPassword;

      if (_client.getNetwork == Network.testnet) {
        clientAddress = fromAddress;
        clientPassword = password;
      } else {
        clientAddress = Env.adminAddress;
        clientPassword = Env.adminPassword;
      }

      developer.log(
        'Executing raw dio transfer: url=$url, from=$fromAddress, to=$toAddress, amount=$amount, currencyEnum=${currencyEnum.name}',
        name: 'TransferRepository',
      );

      // [DIO used]
      // dio was used here because the official Toronet SDK's transferCurrency
      // method is currently broken on the testnet (returning 404 ).

      // This raw dio.post bypasses the broken SDK wrapper and hits the node API directly to ensure transfers succeed.
      // replace with this if you want to use the main net
      //   final result = await _client.currency.transferCurrency(
      //   currency: currencyEnum,
      //   from: fromAddress,
      //   to: toAddress,
      //   amount: amount,
      //   fromPassword: password,
      // );

      final response = await dio.post(
        url,
        data: {
          'op': 'transfer',
          'params': [
            {'name': 'client', 'value': clientAddress},
            {'name': 'clientpwd', 'value': clientPassword},
            {'name': 'from', 'value': fromAddress},
            {'name': 'frompwd', 'value': password},
            {'name': 'to', 'value': toAddress},
            {'name': 'val', 'value': amount},
          ],
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => true,
        ),
      );

      if (response.statusCode != 200) {
        throw ServerFailure(
          'Toronet node responded with status ${response.statusCode}',
        );
      }

      final dynamic rawData = response.data;
      final Map<String, dynamic> responseMap;
      if (rawData is String) {
        responseMap = jsonDecode(rawData) as Map<String, dynamic>;
      } else if (rawData is Map) {
        responseMap = Map<String, dynamic>.from(rawData);
      } else {
        throw const ServerFailure(
          'Invalid response structure from transfer endpoint',
        );
      }

      if (responseMap['result'] == false) {
        throw ServerFailure(
          responseMap['error']?.toString() ?? 'Transfer execution failed',
        );
      }

      final txHash =
          responseMap['transaction']?.toString() ??
          responseMap['txhash']?.toString() ??
          responseMap['txId']?.toString() ??
          '';

      return txHash;
    } on ValidationException catch (e) {
      throw ValidationFailure(e.message);
    } on APIException catch (e) {
      throw ServerFailure(e.message);
    } on ToroSDKException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Transfer failed: $e');
    }
  }

  Future<void> _ensureEnrolled(
    Dio dio,
    String nodeUrl,
    String currencyStr,
    String address,
  ) async {
    if (currencyStr != 'dollar' && currencyStr != 'naira') {
      return;
    }
    try {
      final enrollUrl = '$nodeUrl/currency/$currencyStr/ad';
      final enrollResponse = await dio.post(
        enrollUrl,
        data: {
          'op': 'enrollcurrencyaccount',
          'params': [
            {'name': 'admin', 'value': Env.testnetSuperAdminAddress},
            {'name': 'adminpwd', 'value': Env.testnetSuperAdminPassword},
            {'name': 'addr', 'value': address},
          ],
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final dynamic rawEnrollData = enrollResponse.data;
      final Map<String, dynamic> enrollMap;
      if (rawEnrollData is String) {
        enrollMap = jsonDecode(rawEnrollData) as Map<String, dynamic>;
      } else if (rawEnrollData is Map) {
        enrollMap = Map<String, dynamic>.from(rawEnrollData);
      } else {
        return;
      }

      if (enrollMap['result'] == false) {
        print(
          'Failed to enroll $address in $currencyStr: ${enrollMap['error']}',
        );
      } else {
        print(
          'Successfully enrolled $address in $currencyStr: ${enrollMap['transaction']}',
        );
      }
    } catch (e) {
      print('Error enrolling $address: $e');
    }
  }
}
