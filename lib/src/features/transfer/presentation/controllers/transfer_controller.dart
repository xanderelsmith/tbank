import 'package:flutter/material.dart';
import '../../domain/repositories/transfer_repository.dart';

class TransferController extends ChangeNotifier {
  final TransferRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _resolvedAddress;
  bool _isResolvingTNS = false;

  TransferController(this._repository);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get resolvedAddress => _resolvedAddress;
  bool get isResolvingTNS => _isResolvingTNS;

  Future<String?> resolveRecipient(String recipientInput) async {
    // If it's already an address format, return it directly
    if (recipientInput.startsWith('0x') && recipientInput.length == 42) {
      _resolvedAddress = recipientInput;
      notifyListeners();
      return recipientInput;
    }

    _isResolvingTNS = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final addr = await _repository.resolveTNS(recipientInput);
      _resolvedAddress = addr;
      return addr;
    } catch (e) {
      _errorMessage = 'TNS Resolution failed: ${e.toString()}';
      _resolvedAddress = null;
      return null;
    } finally {
      _isResolvingTNS = false;
      notifyListeners();
    }
  }

  Future<String?> executeTransfer({
    required String fromAddress,
    required String toAddress,
    required String amount,
    required String currency,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final txHash = await _repository.transfer(
        fromAddress: fromAddress,
        toAddress: toAddress,
        amount: amount,
        currency: currency,
        password: password,
      );
      return txHash;
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
    _resolvedAddress = null;
    _isLoading = false;
    _isResolvingTNS = false;
    notifyListeners();
  }
}
