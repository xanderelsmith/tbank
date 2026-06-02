import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:hex/hex.dart';
import 'package:web3dart/web3dart.dart' as web3;

void main() {
  final mnemonic = 'basic month powder maple win test reward gun kiss own champion crouch';
  final seed = bip39.mnemonicToSeed(mnemonic);
  final root = bip32.BIP32.fromSeed(seed);
  final child = root.derivePath("m/44'/60'/0'/0/0");
  final privateKey = child.privateKey;
  final privateKeyHex = HEX.encode(privateKey!);
  
  final credentials = web3.EthPrivateKey.fromHex(privateKeyHex);
  final address = credentials.address.hexEip55;
  
  print('PrivateKey: 0x$privateKeyHex');
  print('Address: $address');
}
