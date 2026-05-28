import 'package:toronet/toronet.dart';
import '../../../../core/services/toronet_client.dart';
import '../../../../core/util/env.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/virtual_account_entity.dart';
import '../../domain/repositories/virtual_wallet_repository.dart';

class VirtualWalletRepositoryImpl implements VirtualWalletRepository {
  final ToronetClient _client;

  VirtualWalletRepositoryImpl(this._client);

  @override
  Future<VirtualAccountEntity> createVirtualAccount({required String address}) async {
    try {
      final result = await _client.virtual.createVirtualWallet(
        address: address,
        payername: 'TBank Customer',
        currency: 'NGN',
        admin: Env.adminAddress,
        adminPassword: Env.adminPassword,
      );

      return _mapToEntity(result, address);
    } on APIException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to create virtual account: $e');
    }
  }

  @override
  Future<VirtualAccountEntity?> fetchVirtualAccount({required String address}) async {
    try {
      final result = await _client.virtual.fetchVirtualWalletByAddress(
        address: address,
        admin: Env.adminAddress,
        adminPassword: Env.adminPassword,
      );

      if (result == null || result.isEmpty) {
        return null;
      }

      return _mapToEntity(result, address);
    } catch (e) {
      // Return null or handle as failure. Standard approach is return null if not found.
      return null;
    }
  }

  VirtualAccountEntity _mapToEntity(dynamic result, String address) {
    if (result is Map) {
      final bankName = result['bankName']?.toString() ?? result['bank']?.toString() ?? 'Simulated Bank';
      final accountNumber = result['accountNumber']?.toString() ?? result['accountNo']?.toString() ?? '';
      final accountName = result['accountName']?.toString() ?? result['name']?.toString() ?? result['payername']?.toString() ?? 'TBank Customer';

      return VirtualAccountEntity(
        bankName: bankName,
        accountNumber: accountNumber,
        accountName: accountName,
        address: address,
      );
    }
    throw const ServerFailure('Invalid response from virtual wallet service');
  }
}
