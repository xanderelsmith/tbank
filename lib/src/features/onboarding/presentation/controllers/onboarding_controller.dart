import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:tbank/src/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../../../core/util/crypto_util.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../../../core/services/notification_service.dart';

class OnboardingController extends ChangeNotifier {
  final OnboardingRepositoryImpl _repository;

  WalletEntity? _activeWallet;
  NotificationService? _notificationService;
  bool _isLoading = false;
  String? _errorMessage;
  bool? _isTnsAvailable;

  NotificationService? get notificationService => _notificationService;

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
      _startNotificationService();
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

      final savedWallet = WalletEntity(
        address: wallet.address,
        username: wallet.username,
        privateKey: wallet.privateKey,
      );

      await _repository.saveWallet(savedWallet);
      _activeWallet = savedWallet;
      developer.log('createWallet success: address=${wallet.address}', name: 'OnboardingController');
      _startNotificationService();
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

  /// Generates a new seed phrase, derives private key, and registers via importWallet
  Future<String?> createWalletWithSeed({
    required String username,
    required String pin,
  }) async {
    developer.log('createWalletWithSeed: username=$username', name: 'OnboardingController');
    _setLoading(true);
    _errorMessage = null;
    try {
      final mnemonic = CryptoUtil.generateMnemonic();
      final privateKey = CryptoUtil.derivePrivateKey(mnemonic);
      
      final wallet = await _repository.importWallet(
        privateKey: privateKey,
        username: username,
        password: pin, // User's PIN replaces password
      );

      final savedWallet = WalletEntity(
        address: wallet.address,
        username: wallet.username,
        privateKey: wallet.privateKey,
      );

      await _repository.saveWallet(savedWallet);
      _activeWallet = savedWallet;
      developer.log('createWalletWithSeed success: address=${wallet.address}', name: 'OnboardingController');
      _startNotificationService();
      notifyListeners();
      return mnemonic; // Return the 12-words to show the user
    } catch (e) {
      developer.log('createWalletWithSeed error: $e', name: 'OnboardingController', error: e);
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> importWallet({
    required String input, // Can be private key or mnemonic
    required String username,
    required String password,
  }) async {
    developer.log('importWallet: username=$username', name: 'OnboardingController');
    _setLoading(true);
    _errorMessage = null;
    try {
      String privateKey = input;
      if (CryptoUtil.isValidMnemonic(input.trim())) {
        privateKey = CryptoUtil.derivePrivateKey(input.trim());
      } else if (!input.startsWith('0x') && input.length != 64 && input.length != 66) {
         throw Exception('Invalid private key or seed phrase format');
      }

      final wallet = await _repository.importWallet(
        privateKey: privateKey,
        username: username,
        password: password,
      );

      await _repository.saveWallet(wallet);
      _activeWallet = wallet;
      developer.log('importWallet success: address=${wallet.address}', name: 'OnboardingController');
      _startNotificationService();
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
    _stopNotificationService();
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

  void _startNotificationService() {
    _stopNotificationService();
    final wallet = _activeWallet;
    if (wallet != null) {
      developer.log('Starting NotificationService for address: ${wallet.address}', name: 'OnboardingController');
      _notificationService = NotificationService(
        nodeUrl: _repository.client.nodeUrl,
        walletAddress: wallet.address,
      );
      _notificationService!.start();
    }
  }

  void _stopNotificationService() {
    if (_notificationService != null) {
      developer.log('Stopping NotificationService...', name: 'OnboardingController');
      _notificationService!.stop();
      _notificationService = null;
    }
  }

  @override
  void dispose() {
    _stopNotificationService();
    super.dispose();
  }
}
