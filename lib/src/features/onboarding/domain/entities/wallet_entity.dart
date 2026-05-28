import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final String address;
  final String username;
  final String? privateKey;

  const WalletEntity({
    required this.address,
    required this.username,
    this.privateKey,
  });

  @override
  List<Object?> get props => [address, username, privateKey];
}
