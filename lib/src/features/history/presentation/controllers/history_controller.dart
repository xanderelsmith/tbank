import 'package:flutter/material.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryController extends ChangeNotifier {
  final HistoryRepository _repository;

  List<TransactionEntity> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  HistoryController(this._repository);

  List<TransactionEntity> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTransactions(String address) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _repository.getTransactions(address: address);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    _transactions = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
