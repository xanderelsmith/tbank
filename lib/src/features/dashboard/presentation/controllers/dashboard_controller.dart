import 'package:flutter/material.dart';
import '../../domain/entities/token_balance.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardController extends ChangeNotifier {
  final DashboardRepository _repository;

  List<TokenBalance> _balances = [];
  bool _isLoading = false;
  String? _errorMessage;

  DashboardController(this._repository);

  List<TokenBalance> get balances => _balances;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBalances(String address) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _balances = await _repository.getBalances(address: address);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
