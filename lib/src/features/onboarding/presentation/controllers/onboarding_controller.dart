import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:tbank/src/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../domain/entities/wallet_entity.dart';

class OnboardingController extends ChangeNotifier {
  final OnboardingRepositoryImpl _repository;

  WalletEntity? _activeWallet;
  bool _isLoading = false;
  String? _errorMessage;
  bool? _isTnsAvailable;

  OnboardingController(this._repository) {
    developer.log('Initializing OnboardingController...', name: 'OnboardingController');
    _loadSavedWallet();
  }

  WalletEntity? get activeWallet => _activeWallet;
  bool get isAuthenticated => _activeWallet != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool? get isTnsAvailable => _isTnsAvailable;

  Future<void> _loadSavedWallet() async {
    developer.log('Loading saved wallet...', name: 'OnboardingController');
    _setLoading(true);
    try {
      _activeWallet = await _repository.getSavedWallet();
      developer.log('Loaded saved wallet: activeWallet=${_activeWallet?.address}', name: 'OnboardingController');
    } catch (e) {
      developer.log('Error loading saved wallet: $e', name: 'OnboardingController', error: e);
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkTNSAvailability(String username) async {
    if (username.trim().isEmpty) {
      _isTnsAvailable = null;
      notifyListeners();
      return;
    }
    developer.log('Checking TNS availability for: $username', name: 'OnboardingController');
    try {
      _isTnsAvailable = await _repository.isTNSAvailable(username: username);
      developer.log('TNS availability result for $username: $_isTnsAvailable', name: 'OnboardingController');
    } catch (e) {
      developer.log('TNS check error: $e', name: 'OnboardingController', error: e);
      _isTnsAvailable = false;
    }
    notifyListeners();
  }

  Future<bool> createWallet({
    required String username,
    required String password,
  }) async {
    developer.log('createWallet: username=$username', name: 'OnboardingController');
    _setLoading(true);
    _errorMessage = null;
    try {
      final wallet = await _repository.createWallet(
        username: username,
        password: password,
      );

      // Save password and details in state wallet
      final savedWallet = WalletEntity(
        address: wallet.address,
        username: wallet.username,
        privateKey: wallet.privateKey,
      );

      await _repository.saveWallet(savedWallet);
      _activeWallet = savedWallet;
      developer.log('createWallet success: address=${wallet.address}', name: 'OnboardingController');
      notifyListeners();
      return true;
    } catch (e) {
      developer.log('createWallet error: $e', name: 'OnboardingController', error: e);
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> importWallet({
    required String privateKey,
    required String username,
    required String password,
  }) async {
    developer.log('importWallet: username=$username', name: 'OnboardingController');
    _setLoading(true);
    _errorMessage = null;
    try {
      final wallet = await _repository.importWallet(
        privateKey: privateKey,
        username: username,
        password: password,
      );

      await _repository.saveWallet(wallet);
      _activeWallet = wallet;
      developer.log('importWallet success: address=${wallet.address}', name: 'OnboardingController');
      notifyListeners();
      return true;
    } catch (e) {
      developer.log('importWallet error: $e', name: 'OnboardingController', error: e);
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    developer.log('logout active wallet: ${_activeWallet?.address}', name: 'OnboardingController');
    _setLoading(true);
    try {
      await _repository.deleteWallet();
      _activeWallet = null;
      _isTnsAvailable = null;
      _errorMessage = null;
      developer.log('logout success', name: 'OnboardingController');
    } catch (e) {
      developer.log('logout error: $e', name: 'OnboardingController', error: e);
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    developer.log('clearError', name: 'OnboardingController');
    _errorMessage = null;
    notifyListeners();
  }
}
