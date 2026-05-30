import '../entities/bank_entity.dart';

abstract class PaymentRepository {
  bool get isTestnet;

  Future<String> initiateDeposit({
    required String amount,
    required String currency,
    required String address,
  });

  Future<bool> confirmDeposit({
    required String paymentId,
    required String amount,
  });

  Future<List<BankEntity>> getBanks({required String currency});

  Future<String> verifyBankAccount({
    required String bankCode,
    required String accountNumber,
  });

  Future<String> withdraw({
    required String address,
    required String amount,
    required String currency,
    required String bankCode,
    required String accountNumber,
    required String accountName,
    required String password,
  });
}
