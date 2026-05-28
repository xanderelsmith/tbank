import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String txHash;
  final String fromAddress;
  final String toAddress;
  final String amount;
  final String currency;
  final String type; // 'send' or 'receive'
  final DateTime timestamp;
  final String status;

  const TransactionEntity({
    required this.txHash,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.currency,
    required this.type,
    required this.timestamp,
    required this.status,
  });

  @override
  List<Object?> get props => [
        txHash,
        fromAddress,
        toAddress,
        amount,
        currency,
        type,
        timestamp,
        status,
      ];
}
