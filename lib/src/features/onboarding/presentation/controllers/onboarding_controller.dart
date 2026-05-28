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
    _loadSavedWallet();
  }

  WalletEntity? get activeWallet => _activeWallet;
  bool get isAuthenticated => _activeWallet != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool? get isTnsAvailable => _isTnsAvailable;

  Future<void> _loadSavedWallet() async {
    _setLoading(true);
    try {
      _activeWallet = await _repository.getSavedWallet();
    } catch (e) {
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
    try {
      _isTnsAvailable = await _repository.isTNSAvailable(username: username);
    } catch (_) {
      _isTnsAvailable = false;
    }
    notifyListeners();
  }

  Future<bool> createWallet({
    required String username,
    required String password,
  }) async {
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
      notifyListeners();
      return true;
    } catch (e) {
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
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _repository.deleteWallet();
      _activeWallet = null;
      _isTnsAvailable = null;
      _errorMessage = null;
    } catch (e) {
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
    _errorMessage = null;
    notifyListeners();
  }
}
