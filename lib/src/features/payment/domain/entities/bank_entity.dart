import 'package:equatable/equatable.dart';

class BankEntity extends Equatable {
  final String code;
  final String name;

  const BankEntity({
    required this.code,
    required this.name,
  });

  @override
  List<Object?> get props => [code, name];
}
