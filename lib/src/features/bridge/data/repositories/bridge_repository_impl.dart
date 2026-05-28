import 'package:toronet/toronet.dart';
import '../../../../core/services/toronet_client.dart';
import '../../../../core/util/env.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/bridge_repository.dart';

class BridgeRepositoryImpl implements BridgeRepository {
  final ToronetClient _client;

  BridgeRepositoryImpl(this._client);

  @override
  Future<String> getBridgeBalance({
    required String address,
    required String chain,
  }) async {
    try {
      final dynamic response;
      switch (chain.toLowerCase()) {
        case 'solana':
          response = await _client.solana.getSolBalance(
            address: address,
            admin: Env.adminAddress,
            adminpwd: Env.adminPassword,
          );
          break;
        case 'polygon':
          response = await _client.polygon.getBalance(
            address: address,
            admin: Env.adminAddress,
            adminpwd: Env.adminPassword,
          );
          break;
        case 'bsc':
          response = await _client.bsc.getBalance(
            address: address,
            admin: Env.adminAddress,
            adminpwd: Env.adminPassword,
          );
          break;
        case 'base':
          response = await _client.base.getBalance(
            address: address,
            admin: Env.adminAddress,
            adminpwd: Env.adminPassword,
          );
          break;
        case 'arbitrum':
          response = await _client.arbitrum.getBalance(
            address: address,
            admin: Env.adminAddress,
            adminpwd: Env.adminPassword,
          );
          break;
        default:
          response = '0.00';
      }
      
      if (response is Map) {
        return response['balance']?.toString() ?? response['result']?.toString() ?? '0.00';
      }
      return response.toString();
    } catch (e) {
      throw ServerFailure('Failed to fetch $chain balance: $e');
    }
  }

  @override
  Future<String> getBridgeFee({
    required String contractAddress,
    required String amount,
    required String chain,
  }) async {
    try {
      // Different chains might have distinct fee query methods;
      // Default to Solana bridge token fee or a mock estimate if unimplemented
      if (chain.toLowerCase() == 'solana') {
        final response = await _client.solana.getBridgeTokenFee(
          contractAddress: contractAddress,
          amount: amount,
          admin: Env.adminAddress,
          adminpwd: Env.adminPassword,
        );
        if (response is Map) {
          return response['fee']?.toString() ?? response['result']?.toString() ?? '0.50';
        }
        return response.toString();
      }
      // For other chains we return a simulated static fee (e.g. '0.5')
      return '0.50';
    } catch (_) {
      return '0.50';
    }
  }

  @override
  Future<String> bridgeToken({
    required String sourceChain,
    required String fromAddress,
    required String password,
    required String tokenName,
    required String amount,
    required String contractAddress,
  }) async {
    try {
      final dynamic response;
      switch (sourceChain.toLowerCase()) {
        case 'solana':
          response = await _client.solana.bridgeToken(
            from: fromAddress,
            password: password,
            contractAddress: contractAddress,
            tokenName: tokenName,
            amount: amount,
            admin: Env.adminAddress,
            adminpwd: Env.adminPassword,
          );
          break;
        case 'polygon':
          response = await _client.polygon.bridgeToken(
            from: fromAddress,
            password: password,
            contractAddress: contractAddress,
            tokenName: tokenName,
            amount: amount,
            admin: Env.adminAddress,
            adminpwd: Env.adminPassword,
          );
          break;
        case 'bsc':
          response = await _client.bsc.bridgeToken(
            from: fromAddress,
            password: password,
            contractAddress: contractAddress,
            tokenName: tokenName,
            amount: amount,
            admin: Env.adminAddress,
            adminpwd: Env.adminPassword,
          );
          break;
        case 'base':
          response = await _client.base.bridgeToken(
            from: fromAddress,
            password: password,
            contractAddress: contractAddress,
            tokenName: tokenName,
            amount: amount,
            admin: Env.adminAddress,
            adminpwd: Env.adminPassword,
          );
          break;
        case 'arbitrum':
          response = await _client.arbitrum.bridgeToken(
            from: fromAddress,
            password: password,
            contractAddress: contractAddress,
            tokenName: tokenName,
            amount: amount,
            admin: Env.adminAddress,
            adminpwd: Env.adminPassword,
          );
          break;
        default:
          throw ServerFailure('Unsupported bridge source chain: $sourceChain');
      }
      
      if (response is Map) {
        return response['result']?.toString() ?? response['txhash']?.toString() ?? response['txId']?.toString() ?? response.toString();
      }
      return response.toString();
    } on APIException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Bridging transaction failed: $e');
    }
  }
}
