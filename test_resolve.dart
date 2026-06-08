import 'package:toronet/toronet.dart';

void main() async {
  final sdk = ToronetSDK(network: Network.testnet);
  
  try {
    print('xander: ' + (await sdk.tnsService.getAddress(name: 'xander')).toString());
  } catch(e) { print('xander error: ' + e.toString()); }
  
  try {
    print('alice: ' + (await sdk.tnsService.getAddress(name: 'alice')).toString());
  } catch(e) { print('alice error: ' + e.toString()); }
  
  try {
    print('tyon: ' + (await sdk.tnsService.getAddress(name: 'tyon')).toString());
  } catch(e) { print('tyon error: ' + e.toString()); }
}
