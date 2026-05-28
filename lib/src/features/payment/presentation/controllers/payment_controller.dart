import 'package:flutter/material.dart';
import '../../domain/entities/bank_entity.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentController extends ChangeNotifier {
  final PaymentRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;

  List<BankEntity> _banks = [];
  bool _isLoadingBanks = false;

  String? _verifiedAccountName;
  bool _isVerifyingAccount = false;

  String? _depositReference;
  bool _depositSuccess = false;

  PaymentController(this._repository);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BankEntity> get banks => _banks;
  bool get isLoadingBanks => _isLoadingBanks;
  String? get verifiedAccountName => _verifiedAccountName;
  bool get isVerifyingAccount => _isVerifyingAccount;
  String? get depositReference => _depositReference;
  bool get depositSuccess => _depositSuccess;

  Future<void> fetchBanks(String currency) async {
    _isLoadingBanks = true;
    _errorMessage = null;
    _banks = [];
    notifyListeners();

    try {
      _banks = await _repository.getBanks(currency: currency);
    } catch (e) {
      _errorMessage = 'Failed to load bank list: ${e.toString()}';
    } finally {
      _isLoadingBanks = false;
      notifyListeners();
    }
  }

  Future<String?> verifyAccount({
    required String bankCode,
    required String accountNumber,
  }) async {
    _isVerifyingAccount = true;
    _errorMessage = null;
    _verifiedAccountName = null;
    notifyListeners();

    try {
      final name = await _repository.verifyBankAccount(
        bankCode: bankCode,
        accountNumber: accountNumber,
      );
      _verifiedAccountName = name;
      return name;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isVerifyingAccount = false;
      notifyListeners();
    }
  }

  Future<bool> initiateDeposit({
    required String amount,
    required String currency,
    required String address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _depositReference = null;
    _depositSuccess = false;
    notifyListeners();

    try {
      final ref = await _repository.initiateDeposit(
        amount: amount,
        currency: currency,
        address: address,
      );
      _depositReference = ref;
      _depositSuccess = true;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmDeposit({
    required String paymentId,
    required String amount,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final verified = await _repository.confirmDeposit(
        paymentId: paymentId,
        amount: amount,
      );
      return verified;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> executeWithdrawal({
    required String address,
    required String amount,
    required String currency,
    required String bankCode,
    required String accountNumber,
    required String accountName,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final txHash = await _repository.withdraw(
        address: address,
        amount: amount,
        currency: currency,
        bankCode: bankCode,
        accountNumber: accountNumber,
        accountName: accountName,
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
    _depositReference = null;
    _depositSuccess = false;
    _verifiedAccountName = null;
    _isVerifyingAccount = false;
    _isLoading = false;
    notifyListeners();
  }
}
