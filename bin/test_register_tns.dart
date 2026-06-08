import 'package:toronet/toronet.dart';

void main() async {
  final sdk = ToronetSDK(
    network: Network.testnet, 
    baseUrl: 'https://testnet.toronet.org/api'
  );
  
  // The global Super Admin credentials that have permission to register names on the testnet
  final adminAddress = '0x43F78b342084e370f10e0Cd07d56d95c1728C9D4';
  final adminPassword = 'toronet';

  // We need to fetch their actual 0x addresses from your app's creation or 
  // you can generate new ones to link. For this test, I will register them 
  // to dummy addresses so they resolve. 
  try {
    print('Registering alice...');
    await sdk.tnsService.adminSetName(
      admin: adminAddress,
      adminPassword: adminPassword,
      address: '0x1234567890abcdef1234567890abcdef12345678', // Replace with alice's real 0x address
      name: 'alice',
    );
    print('alice successfully registered on TNS!');
    
    print('Registering tyon...');
    await sdk.tnsService.adminSetName(
      admin: adminAddress,
      adminPassword: adminPassword,
      address: '0xabcdef1234567890abcdef1234567890abcdef12', // Replace with tyon's real 0x address
      name: 'tyon',
    );
    print('tyon successfully registered on TNS!');
    
  } catch(e) {
    print('Failed to register: $e');
  }
}
