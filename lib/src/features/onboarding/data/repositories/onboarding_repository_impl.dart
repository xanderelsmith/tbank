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
    String finalAddress;
    try {
      final wallet = await _client.wallet.importWalletFromPrivateKey(
        privateKey: privateKey,
        password: password,
      );
      finalAddress = wallet.address;
      log('importWallet request succeeded: address=$finalAddress');
    } catch (e) {
      if (e.toString().contains('Duplicated keystore record found')) {
        log('Keystore already exists on node. Resolving address locally.');
        try {
          finalAddress = CryptoUtil.getAddressFromPrivateKey(privateKey);
        } catch (innerErr) {
          log('Failed to derive address locally: $innerErr', error: innerErr);
          throw ServerFailure('Duplicated keystore record found, but failed to derive address locally.');
        }
      } else {
        log('importWallet unexpected error: $e', error: e);
        throw ServerFailure('An unexpected error occurred: $e');
      }
    }

    final resolvedUsername = await _resolveOrRegisterTns(finalAddress, username);
    return WalletEntity(
      address: finalAddress,
      username: resolvedUsername,
      privateKey: privateKey,
    );
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
  Future<String> _resolveOrRegisterTns(String address, String fallbackUsername) async {
    log('==================================================', name: 'TNS_IMPORT');
    log('Checking TNS registry for existing username for address: $address', name: 'TNS_IMPORT');
    try {
      final res = await _client.tns.getName(address: address);
      final existingName = res['name']?.toString() ?? res['result']?.toString() ?? '';
      
      // If we found a valid 4+ letter name on the blockchain, RESTORE IT!
      if (existingName.isNotEmpty && existingName != 'null' && existingName.length >= 4 && !existingName.contains(' ')) {
        log('SUCCESS: Restored existing blockchain username: $existingName', name: 'TNS_IMPORT');
        log('==================================================', name: 'TNS_IMPORT');
        return existingName;
      }
    } catch (e) {
      log('No existing username found or error fetching: $e', name: 'TNS_IMPORT');
    }

    // If no existing name, register the one they typed in the UI
    log('Attempting to register new username $fallbackUsername on TNS...', name: 'TNS_IMPORT');
    try {
      await _client.tns.adminSetName(
        admin: Env.testnetSuperAdminAddress,
        adminPassword: Env.testnetSuperAdminPassword,
        address: address,
        name: fallbackUsername,
      );
      log('SUCCESS: $fallbackUsername is now officially registered!', name: 'TNS_IMPORT');
    } catch (e) {
      log('FAILED: Registration failed for $fallbackUsername. Error: $e', name: 'TNS_IMPORT');
    }
    log('==================================================', name: 'TNS_IMPORT');
    return fallbackUsername;
  }
}
