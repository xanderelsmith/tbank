import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:hex/hex.dart';
import 'package:web3dart/web3dart.dart' as web3;

class CryptoUtil {
  /// Generates a 12-word seed phrase
  static String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  /// Derives the private key from a given 12-word seed phrase
  /// using the standard Ethereum derivation path (m/44'/60'/0'/0/0)
  static String derivePrivateKey(String mnemonic) {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic phrase');
    }
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final child = root.derivePath("m/44'/60'/0'/0/0");
    final privateKey = child.privateKey;
    if (privateKey == null) {
      throw Exception('Failed to derive private key');
    }
    return '0x${HEX.encode(privateKey)}';
  }

  /// Derives the Ethereum address from a given private key
  static String getAddressFromPrivateKey(String privateKey) {
    if (privateKey.startsWith('0x')) {
      privateKey = privateKey.substring(2);
    }
    final credentials = web3.EthPrivateKey.fromHex(privateKey);
    return credentials.address.hexEip55;
  }

  /// Checks if a string is a valid mnemonic phrase
  static bool isValidMnemonic(String mnemonic) {
    return bip39.validateMnemonic(mnemonic);
  }
}
