import 'package:equatable/equatable.dart';

class BridgeEntity extends Equatable {
  final String sourceChain;
  final String targetChain;
  final String amount;
  final String estimatedFee;
  final String tokenName;

  const BridgeEntity({
    required this.sourceChain,
    required this.targetChain,
    required this.amount,
    required this.estimatedFee,
    required this.tokenName,
  });

  @override
  List<Object?> get props => [sourceChain, targetChain, amount, estimatedFee, tokenName];
}
