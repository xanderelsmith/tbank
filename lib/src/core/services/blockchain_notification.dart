class BlockchainNotification {
  final String title;
  final String body;
  final String type; // 'transfer', 'block', etc.
  final Map<String, dynamic> metadata;

  BlockchainNotification({
    required this.title,
    required this.body,
    required this.type,
    this.metadata = const {},
  });
}
