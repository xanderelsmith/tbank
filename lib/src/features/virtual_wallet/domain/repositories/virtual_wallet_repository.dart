import '../entities/virtual_account_entity.dart';

abstract class VirtualWalletRepository {
  Future<VirtualAccountEntity> createVirtualAccount({required String address});
  Future<VirtualAccountEntity?> fetchVirtualAccount({required String address});
}
