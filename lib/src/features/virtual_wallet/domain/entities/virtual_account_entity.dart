import 'package:equatable/equatable.dart';

class VirtualAccountEntity extends Equatable {
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String address;

  const VirtualAccountEntity({
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.address,
  });

  @override
  List<Object?> get props => [bankName, accountNumber, accountName, address];
}
