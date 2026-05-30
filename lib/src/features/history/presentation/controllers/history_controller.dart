import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:tbank/src/features/history/data/repositories/history_repository_impl.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryController extends ChangeNotifier {
  final HistoryRepositoryImpl _repository;

  List<TransactionEntity> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  HistoryController(this._repository);

  List<TransactionEntity> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTransactions(String address) async {
    developer.log('fetchTransactions: address=$address', name: 'HistoryController');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _repository.getTransactions(address: address);
      developer.log('fetchTransactions success: retrieved ${_transactions.length} transactions', name: 'HistoryController');
    } catch (e) {
      developer.log('Failed to fetch transactions: $e', name: 'HistoryController', error: e);
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    developer.log('clearState', name: 'HistoryController');
    _transactions = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
