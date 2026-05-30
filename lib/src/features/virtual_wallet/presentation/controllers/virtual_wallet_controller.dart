import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../domain/entities/virtual_account_entity.dart';
import '../../domain/repositories/virtual_wallet_repository.dart';

class VirtualWalletController extends ChangeNotifier {
  final VirtualWalletRepository _repository;

  VirtualAccountEntity? _virtualAccount;
  bool _isLoading = false;
  String? _errorMessage;

  VirtualWalletController(this._repository);

  VirtualAccountEntity? get virtualAccount => _virtualAccount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchVirtualAccount(String address) async {
    developer.log('fetchVirtualAccount: address=$address', name: 'VirtualWalletController');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _virtualAccount = await _repository.fetchVirtualAccount(address: address);
      developer.log('fetchVirtualAccount success: accountNo=${_virtualAccount?.accountNumber}', name: 'VirtualWalletController');
    } catch (e) {
      developer.log('fetchVirtualAccount error: $e', name: 'VirtualWalletController', error: e);
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createVirtualAccount(String address) async {
    developer.log('createVirtualAccount: address=$address', name: 'VirtualWalletController');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _virtualAccount = await _repository.createVirtualAccount(address: address);
      developer.log('createVirtualAccount success: accountNo=${_virtualAccount?.accountNumber}', name: 'VirtualWalletController');
    } catch (e) {
      developer.log('createVirtualAccount error: $e', name: 'VirtualWalletController', error: e);
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    developer.log('clearState', name: 'VirtualWalletController');
    _virtualAccount = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
