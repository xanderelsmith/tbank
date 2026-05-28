import 'package:toronet/toronet.dart';
import '../../../../core/services/toronet_client.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/transfer_repository.dart';

class TransferRepositoryImpl implements TransferRepository {
  final ToronetClient _client;

  TransferRepositoryImpl(this._client);

  @override
  Future<String> resolveTNS(String username) async {
    try {
      // Clean up username (TNS name should not have spaces or @ symbols)
      final cleanUsername = username.replaceAll('@', '').trim();
      final response = await _client.tns.getAddress(name: cleanUsername);
      final address = response['result']?.toString() ?? response['address']?.toString() ?? response['addr']?.toString() ?? '';
      if (address.isEmpty || address == '0x0000000000000000000000000000000000000000') {
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
      Currency currencyEnum;
      switch (currency.toUpperCase()) {
        case 'USD':
          currencyEnum = Currency.dollar;
          break;
        case 'NGN':
          currencyEnum = Currency.naira;
          break;
        case 'TOROG':
          currencyEnum = Currency.toro;
          break;
        default:
          currencyEnum = Currency.toro;
      }

      final result = await _client.currency.transferCurrency(
        currency: currencyEnum,
        from: fromAddress,
        to: toAddress,
        amount: amount,
        fromPassword: password,
      );

      final txHash = result['result']?.toString() ?? result['txhash']?.toString() ?? result['txId']?.toString() ?? '';
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
}
