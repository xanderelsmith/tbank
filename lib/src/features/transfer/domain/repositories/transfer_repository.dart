abstract class TransferRepository {
  Future<String> resolveTNS(String username);
  
  Future<String> transfer({
    required String fromAddress,
    required String toAddress,
    required String amount,
    required String currency,
    required String password,
  });
}
