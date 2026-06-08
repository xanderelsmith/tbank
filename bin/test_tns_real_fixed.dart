import 'package:toronet/toronet.dart';

void main() async {
  final sdk = ToronetSDK(
    network: Network.testnet, 
    baseUrl: 'https://testnet.toronet.org/api'
  );
  
  for (var name in ['xander', 'danny', 'alice', 'tyon']) {
    try {
      final res = await sdk.tnsService.getAddress(name: name);
      print('$name: $res');
    } catch(e) {
      print('$name error: $e');
    }
  }
}
