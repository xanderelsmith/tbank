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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _virtualAccount = await _repository.fetchVirtualAccount(address: address);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createVirtualAccount(String address) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _virtualAccount = await _repository.createVirtualAccount(address: address);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    _virtualAccount = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
