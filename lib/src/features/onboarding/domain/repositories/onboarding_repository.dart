import '../entities/wallet_entity.dart';

abstract class OnboardingRepository {
  Future<WalletEntity> createWallet({
    required String username,
    required String password,
  });

  Future<WalletEntity> importWallet({
    required String privateKey,
    required String username,
    required String password,
  });

  Future<bool> verifyPassword({
    required String address,
    required String password,
  });

  Future<void> updatePassword({
    required String address,
    required String oldPassword,
    required String newPassword,
  });

  Future<bool> isTNSAvailable({required String username});

  Future<WalletEntity?> getSavedWallet();

  Future<void> saveWallet(WalletEntity wallet);

  Future<void> deleteWallet();
}
