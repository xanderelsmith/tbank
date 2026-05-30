import 'dart:developer' as developer;
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
    developer.log('selectSourceChain: $chain', name: 'BridgeController');
    _selectedChain = chain;
    notifyListeners();
  }

  Future<void> fetchSourceBalance(String address) async {
    developer.log('fetchSourceBalance: address=$address, chain=$_selectedChain', name: 'BridgeController');
    _isLoadingBalance = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sourceBalance = await _repository.getBridgeBalance(
        address: address,
        chain: _selectedChain,
      );
      developer.log('fetchSourceBalance success: balance=$_sourceBalance', name: 'BridgeController');
    } catch (e) {
      developer.log('fetchSourceBalance error: $e', name: 'BridgeController', error: e);
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
    developer.log('estimateFee: contractAddress=$contractAddress, amount=$amount, chain=$_selectedChain', name: 'BridgeController');
    _isEstimatingFee = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _estimatedFee = await _repository.getBridgeFee(
        contractAddress: contractAddress,
        amount: amount,
        chain: _selectedChain,
      );
      developer.log('estimateFee success: fee=$_estimatedFee', name: 'BridgeController');
    } catch (e) {
      developer.log('estimateFee error: $e', name: 'BridgeController', error: e);
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
    developer.log(
      'executeBridge: fromAddress=$fromAddress, tokenName=$tokenName, amount=$amount, contractAddress=$contractAddress, sourceChain=$_selectedChain',
      name: 'BridgeController',
    );
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
      developer.log('executeBridge success: txHash=$result', name: 'BridgeController');
      return result;
    } catch (e) {
      developer.log('executeBridge error: $e', name: 'BridgeController', error: e);
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    developer.log('clearState', name: 'BridgeController');
    _errorMessage = null;
    _isLoading = false;
    _isLoadingBalance = false;
    _isEstimatingFee = false;
    notifyListeners();
  }
}
