import 'dart:io';

void main() async {
  final domains = [
    'connectworld.com',
    'restapi.connectworld.com',
    'payments.connectworld.com',
    'testnet.connectworld.com',
    'testnet-restapi.connectworld.com',
    'testnet-api.connectworld.com',
  ];

  for (final domain in domains) {
    try {
      final addresses = await InternetAddress.lookup(domain);
      print('RESOLVED $domain -> ${addresses.map((a) => a.address).join(', ')}');
    } catch (_) {}
  }
}
