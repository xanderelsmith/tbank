import 'package:equatable/equatable.dart';

class TokenBalance extends Equatable {
  final String symbol;
  final String name;
  final String amount;

  const TokenBalance({
    required this.symbol,
    required this.name,
    required this.amount,
  });

  @override
  List<Object?> get props => [symbol, name, amount];
}
