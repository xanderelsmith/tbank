abstract class BridgeRepository {
  Future<String> getBridgeBalance({
    required String address,
    required String chain,
  });

  Future<String> getBridgeFee({
    required String contractAddress,
    required String amount,
    required String chain,
  });

  Future<String> bridgeToken({
    required String sourceChain,
    required String fromAddress,
    required String password,
    required String tokenName,
    required String amount,
    required String contractAddress,
  });
}
