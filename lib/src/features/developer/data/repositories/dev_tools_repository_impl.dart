import 'package:toronet/toronet.dart';
import 'package:toronet/src/api/blockchain_api.dart';
import '../../../../core/services/toronet_client.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/dev_tools_repository.dart';

class DevToolsRepositoryImpl implements DevToolsRepository {
  final ToronetClient _client;

  DevToolsRepositoryImpl(this._client);

  @override
  Future<Map<String, dynamic>> getBlockchainStatus() async {
    try {
      return await _client.blockchain.getBlockchainStatus();
    } on APIException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to get blockchain status: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getLatestBlock() async {
    try {
      return await _client.blockchain.getLatestBlockData();
    } on APIException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to get latest block: $e');
    }
  }

  @override
  Future<String> getTransactionRevertReason({required String txHash}) async {
    try {
      final dio = _client.sdk.blockchainService.dio;
      final baseUrl = _client.sdk.blockchainService.baseUrl;
      final result = await getRevertReason(dio, baseUrl, txHash);
      
      // If the result contains a revert reason string, return it
      return result['reason']?.toString() ?? result['message']?.toString() ?? result.toString();
    } catch (e) {
      throw ServerFailure('Failed to get revert reason: $e');
    }
  }
}
