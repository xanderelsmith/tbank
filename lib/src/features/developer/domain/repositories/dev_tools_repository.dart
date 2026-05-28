abstract class DevToolsRepository {
  Future<Map<String, dynamic>> getBlockchainStatus();
  Future<Map<String, dynamic>> getLatestBlock();
  Future<String> getTransactionRevertReason({required String txHash});
}
