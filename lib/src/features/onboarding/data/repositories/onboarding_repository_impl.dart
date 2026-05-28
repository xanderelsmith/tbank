import 'dart:developer';

import 'package:toronet/toronet.dart';
import '../../../../core/services/toronet_client.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final ToronetClient _client;
  final OnboardingLocalDataSource _localDataSource;

  OnboardingRepositoryImpl({
    required ToronetClient client,
    required OnboardingLocalDataSource localDataSource,
  }) : _client = client,
       _localDataSource = localDataSource;

  @override
  Future<WalletEntity> createWallet({
    required String username,
    required String password,
  }) async {
    log(username.toString());
    try {
      final wallet = await _client.wallet.createWallet(
        username: username,
        password: password,
      );
      log(wallet.toString());
      // Attempt to retrieve or set private key/seed details if supported.
      // In the SDK, the wallet object contains public properties like address and tnsName.
      return WalletEntity(
        address: wallet.address,
        username: wallet.tnsName ?? username,
      );
    } on ValidationException catch (e) {
      throw ValidationFailure(e.message);
    } on APIException catch (e) {
      throw ServerFailure(e.message);
    } on ToroSDKException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<WalletEntity> importWallet({
    required String privateKey,
    required String username,
    required String password,
  }) async {
    try {
      // In the SDK: sdk.walletService.importWalletFromPrivateKey(privateKey: ..., password: ...)
      // Let's verify parameter names from our example code in step 64 content.md.
      // Wait, let's check step 64 lines for importWallet:
      // "importWallet requires a private key.\nUse: sdk.walletService.importWalletFromPrivateKey(...)"
      // Let's check how importWalletFromPrivateKey is defined.
      // Let's call importWalletFromPrivateKey(privateKey: privateKey, password: password) or username as well.
      final wallet = await _client.wallet.importWalletFromPrivateKey(
        privateKey: privateKey,
        password: password,
      );

      return WalletEntity(
        address: wallet.address,
        username: username,
        privateKey: privateKey,
      );
    } on ValidationException catch (e) {
      throw ValidationFailure(e.message);
    } on APIException catch (e) {
      throw ServerFailure(e.message);
    } on ToroSDKException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<bool> verifyPassword({
    required String address,
    required String password,
  }) async {
    try {
      return await _client.wallet.verifyWalletPassword(
        address: address,
        password: password,
      );
    } catch (e) {
      throw ServerFailure('Password verification failed: $e');
    }
  }

  @override
  Future<void> updatePassword({
    required String address,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _client.wallet.updateWalletPassword(
        address: address,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } on ValidationException catch (e) {
      throw ValidationFailure(e.message);
    } catch (e) {
      throw ServerFailure('Update password failed: $e');
    }
  }

  @override
  Future<bool> isTNSAvailable({required String username}) async {
    try {
      return await _client.wallet.isTNSAvailable(username: username);
    } catch (e) {
      throw ServerFailure('Failed checking username availability: $e');
    }
  }

  @override
  Future<WalletEntity?> getSavedWallet() {
    return _localDataSource.getSavedWallet();
  }

  @override
  Future<void> saveWallet(WalletEntity wallet) {
    return _localDataSource.saveWallet(wallet);
  }

  @override
  Future<void> deleteWallet() {
    return _localDataSource.deleteWallet();
  }
}
