import 'package:flutter/material.dart';
import '../../domain/repositories/bridge_repository.dart';

class BridgeController extends ChangeNotifier {
  final BridgeRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;

  String _selectedChain = 'Polygon';
  String _targetChain = 'Toronet';
  String _sourceBalance = '0.00';
  String _estimatedFee = '0.50';

  bool _isEstimatingFee = false;
  bool _isLoadingBalance = false;

  BridgeController(this._repository);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedChain => _selectedChain;
  String get targetChain => _targetChain;
  String get sourceBalance => _sourceBalance;
  String get estimatedFee => _estimatedFee;
  bool get isEstimatingFee => _isEstimatingFee;
  bool get isLoadingBalance => _isLoadingBalance;

  void selectSourceChain(String chain) {
    _selectedChain = chain;
    notifyListeners();
  }

  Future<void> fetchSourceBalance(String address) async {
    _isLoadingBalance = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sourceBalance = await _repository.getBridgeBalance(
        address: address,
        chain: _selectedChain,
      );
    } catch (e) {
      _sourceBalance = '0.00';
      _errorMessage = e.toString();
    } finally {
      _isLoadingBalance = false;
      notifyListeners();
    }
  }

  Future<void> estimateFee({
    required String contractAddress,
    required String amount,
  }) async {
    _isEstimatingFee = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _estimatedFee = await _repository.getBridgeFee(
        contractAddress: contractAddress,
        amount: amount,
        chain: _selectedChain,
      );
    } catch (e) {
      _estimatedFee = '0.50';
    } finally {
      _isEstimatingFee = false;
      notifyListeners();
    }
  }

  Future<String?> executeBridge({
    required String fromAddress,
    required String password,
    required String tokenName,
    required String amount,
    required String contractAddress,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.bridgeToken(
        sourceChain: _selectedChain,
        fromAddress: fromAddress,
        password: password,
        tokenName: tokenName,
        amount: amount,
        contractAddress: contractAddress,
      );
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    _errorMessage = null;
    _isLoading = false;
    _isLoadingBalance = false;
    _isEstimatingFee = false;
    notifyListeners();
  }
}
