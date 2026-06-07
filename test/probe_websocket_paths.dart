import 'dart:io';

void main() async {
  final paths = [
    '/ws',
    '/api/ws',
    '/socket',
    '/socket.io',
    '/',
    '/rpc',
    '/api/rpc',
    '/graphql',
    '/v1/ws',
    '/v2/ws',
  ];

  for (final path in paths) {
    final url = 'wss://testnet.toronet.org$path';
    print('\nTesting: $url');
    try {
      final ws = await WebSocket.connect(url).timeout(const Duration(seconds: 5));
      print('✅ SUCCESS: Connection upgraded to WebSocket at $url');
      ws.close();
      return;
    } catch (e) {
      if (e is WebSocketException) {
        print('❌ Failed: ${e.message}');
      } else {
        print('❌ Failed: $e');
      }
    }
  }
}
