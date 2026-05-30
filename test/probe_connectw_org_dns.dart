import 'dart:io';

void main() async {
  final domains = [
    'connectw.org',
    'restapi.connectw.org',
    'payments.connectw.org',
    'testnet.connectw.org',
    'testnet-restapi.connectw.org',
    'testnet-payments.connectw.org',
  ];

  for (final domain in domains) {
    try {
      final addresses = await InternetAddress.lookup(domain);
      print('RESOLVED $domain -> ${addresses.map((a) => a.address).join(', ')}');
    } catch (_) {}
  }
}
