import 'dart:developer';

import 'package:toronet/toronet.dart';
import '../../../../core/services/toronet_client.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/util/crypto_util.dart';
import '../../../../core/util/env.dart';
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

  ToronetClient get client => _client;

  @override
  Future<WalletEntity> createWallet({
    required String username,
    required String password,
  }) async {
    log('createWallet request started for username: $username');
    try {
      final wallet = await _client.wallet.createWallet(
        username: username,
        password: password,
      );

      // --- NEW: Register the name globally on TNS ---
      log(
        '==================================================',
        name: 'TNS_REGISTER',
      );
      log(
        'Attempting to register $username on TNS global registry...',
        name: 'TNS_REGISTER',
      );
      try {
        await _client.tns.adminSetName(
          admin: Env.testnetSuperAdminAddress,
          adminPassword: Env.testnetSuperAdminPassword,
          address: wallet.address,
          name: username,
        );
        log(
          'SUCCESS: $username is now officially registered on the blockchain!',
          name: 'TNS_REGISTER',
        );
      } catch (e) {
        log(
          'FAILED: TNS Registration failed for $username. Error: $e',
          name: 'TNS_REGISTER',
        );
        // We don't throw here because the local wallet was still successfully created.
      }
      log(
        '==================================================',
        name: 'TNS_REGISTER',
      );
      // ----------------------------------------------

      log(
        'createWallet request succeeded: address=${wallet.address}, username=${wallet.tnsName}',
      );
      return WalletEntity(
        address: wallet.address,
        username: wallet.tnsName ?? username,
      );
    } on ValidationException catch (e) {
      log('createWallet ValidationException: ${e.message}', error: e);
      throw ValidationFailure(e.message);
    } on APIException catch (e) {
      log('createWallet APIException: ${e.message}', error: e);
      throw ServerFailure(e.message);
    } on ToroSDKException catch (e) {
      log('createWallet ToroSDKException: ${e.message}', error: e);
      throw ServerFailure(e.message);
    } catch (e) {
      log('createWallet unexpected error: $e', error: e);
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<WalletEntity> importWallet({
    required String privateKey,
    required String username,
    required String password,
  }) async {
    log('importWallet request started for username: $username');
    try {
      final wallet = await _client.wallet.importWalletFromPrivateKey(
        privateKey: privateKey,
        password: password,
      );
      log('importWallet request succeeded: address=${wallet.address}');

      return WalletEntity(
        address: wallet.address,
        username: username,
        privateKey: privateKey,
      );
    } on ValidationException catch (e) {
      log('importWallet ValidationException: ${e.message}', error: e);
      throw ValidationFailure(e.message);
    } on APIException catch (e) {
      log('importWallet APIException: ${e.message}', error: e);
      if (e.message.contains('Duplicated keystore record found')) {
        log('Keystore already exists on node. Resolving address locally.');
        try {
          final address = CryptoUtil.getAddressFromPrivateKey(privateKey);
          return WalletEntity(
            address: address,
            username: username,
            privateKey: privateKey,
          );
        } catch (innerErr) {
          log('Failed to derive address locally: $innerErr', error: innerErr);
          throw ServerFailure(
            'Duplicated keystore record found, but failed to derive address locally.',
          );
        }
      }
      throw ServerFailure(e.message);
    } on ServerFailure catch (e) {
      if (e.message.contains('Duplicated keystore record found')) {
        log('Keystore already exists on node. Resolving address locally.');
        try {
          final address = CryptoUtil.getAddressFromPrivateKey(privateKey);
          return WalletEntity(
            address: address,
            username: username,
            privateKey: privateKey,
          );
        } catch (innerErr) {
          log('Failed to derive address locally: $innerErr', error: innerErr);
          throw ServerFailure(
            'Duplicated keystore record found, but failed to derive address locally.',
          );
        }
      }
      rethrow;
    } on ToroSDKException catch (e) {
      log('importWallet ToroSDKException: ${e.message}', error: e);
      if (e.message.contains('Duplicated keystore record found')) {
        log('Keystore already exists on node. Resolving address locally.');
        try {
          final address = CryptoUtil.getAddressFromPrivateKey(privateKey);
          return WalletEntity(
            address: address,
            username: username,
            privateKey: privateKey,
          );
        } catch (innerErr) {
          log('Failed to derive address locally: $innerErr', error: innerErr);
          throw ServerFailure(
            'Duplicated keystore record found, but failed to derive address locally.',
          );
        }
      }
      throw ServerFailure(e.message);
    } catch (e) {
      log('importWallet unexpected error: $e', error: e);
      if (e.toString().contains('Duplicated keystore record found')) {
        log('Keystore already exists on node. Resolving address locally.');
        try {
          final address = CryptoUtil.getAddressFromPrivateKey(privateKey);
          return WalletEntity(
            address: address,
            username: username,
            privateKey: privateKey,
          );
        } catch (innerErr) {
          log('Failed to derive address locally: $innerErr', error: innerErr);
          throw ServerFailure(
            'Duplicated keystore record found, but failed to derive address locally.',
          );
        }
      }
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<bool> verifyPassword({
    required String address,
    required String password,
  }) async {
    log('verifyPassword request started for address: $address');
    try {
      final result = await _client.wallet.verifyWalletPassword(
        address: address,
        password: password,
      );
      log('verifyPassword request succeeded: result=$result');
      return result;
    } catch (e) {
      log('verifyPassword failed for address $address: $e', error: e);
      throw ServerFailure('Password verification failed: $e');
    }
  }

  @override
  Future<void> updatePassword({
    required String address,
    required String oldPassword,
    required String newPassword,
  }) async {
    log('updatePassword request started for address: $address');
    try {
      await _client.wallet.updateWalletPassword(
        address: address,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      log('updatePassword request succeeded for address: $address');
    } on ValidationException catch (e) {
      log('updatePassword ValidationException: ${e.message}', error: e);
      throw ValidationFailure(e.message);
    } catch (e) {
      log('updatePassword failed: $e', error: e);
      throw ServerFailure('Update password failed: $e');
    }
  }

  @override
  Future<bool> isTNSAvailable({required String username}) async {
    log('isTNSAvailable request started for username: $username');
    try {
      final result = await _client.wallet.isTNSAvailable(username: username);
      log('isTNSAvailable request succeeded: result=$result');
      return result;
    } catch (e) {
      log('isTNSAvailable failed: $e', error: e);
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
