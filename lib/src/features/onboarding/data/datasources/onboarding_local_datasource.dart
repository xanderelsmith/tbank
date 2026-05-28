import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/wallet_entity.dart';

abstract class OnboardingLocalDataSource {
  Future<WalletEntity?> getSavedWallet();
  Future<void> saveWallet(WalletEntity wallet);
  Future<void> deleteWallet();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  static const String _keyAddress = 'active_wallet_address';
  static const String _keyUsername = 'active_wallet_username';
  static const String _keyPrivateKey = 'active_wallet_private_key';

  final SharedPreferences _sharedPrefs;

  OnboardingLocalDataSourceImpl(this._sharedPrefs);

  @override
  Future<WalletEntity?> getSavedWallet() async {
    final address = _sharedPrefs.getString(_keyAddress);
    final username = _sharedPrefs.getString(_keyUsername);
    final privateKey = _sharedPrefs.getString(_keyPrivateKey);

    if (address != null && username != null) {
      return WalletEntity(
        address: address,
        username: username,
        privateKey: privateKey,
      );
    }
    return null;
  }

  @override
  Future<void> saveWallet(WalletEntity wallet) async {
    await _sharedPrefs.setString(_keyAddress, wallet.address);
    await _sharedPrefs.setString(_keyUsername, wallet.username);
    if (wallet.privateKey != null) {
      await _sharedPrefs.setString(_keyPrivateKey, wallet.privateKey!);
    } else {
      await _sharedPrefs.remove(_keyPrivateKey);
    }
  }

  @override
  Future<void> deleteWallet() async {
    await _sharedPrefs.remove(_keyAddress);
    await _sharedPrefs.remove(_keyUsername);
    await _sharedPrefs.remove(_keyPrivateKey);
  }
}
