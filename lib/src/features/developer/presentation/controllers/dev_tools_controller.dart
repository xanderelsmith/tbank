import 'package:flutter/material.dart';
import '../../domain/repositories/dev_tools_repository.dart';

class DevToolsController extends ChangeNotifier {
  final DevToolsRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? _blockchainStatus;
  Map<String, dynamic>? _latestBlock;
  String? _revertReason;
  bool _isAnalyzingRevert = false;

  DevToolsController(this._repository);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get blockchainStatus => _blockchainStatus;
  Map<String, dynamic>? get latestBlock => _latestBlock;
  String? get revertReason => _revertReason;
  bool get isAnalyzingRevert => _isAnalyzingRevert;

  Future<void> fetchDiagnostics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getBlockchainStatus(),
        _repository.getLatestBlock(),
      ]);
      _blockchainStatus = results[0];
      _latestBlock = results[1];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> analyzeRevertReason(String txHash) async {
    if (txHash.trim().isEmpty) return null;
    
    _isAnalyzingRevert = true;
    _revertReason = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final reason = await _repository.getTransactionRevertReason(txHash: txHash);
      _revertReason = reason;
      return reason;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isAnalyzingRevert = false;
      notifyListeners();
    }
  }

  void clearState() {
    _blockchainStatus = null;
    _latestBlock = null;
    _revertReason = null;
    _errorMessage = null;
    _isLoading = false;
    _isAnalyzingRevert = false;
    notifyListeners();
  }
}
