import 'dart:io';

void main() async {
  final domains = [
    'website.toronet.org',
    'testnet-website.toronet.org',
    'website-testnet.toronet.org',
    'testnet.connectw.com',
    'testnet-payments.connectw.com',
    'testnet-restapi.connectw.com',
    'sandbox-payments.connectw.com',
    'sandbox-restapi.connectw.com',
    'api-sandbox.connectw.com',
    'sandbox-api.connectw.com',
    'sandbox.connectw.com',
    'restapi.toronet.org',
    'api.toronet.org',
    'testnet.toronet.org',
    'connectw.toronet.org',
    'payments.toronet.org',
    'payment.toronet.org',
    'api.connectw.com',
  ];

  for (final domain in domains) {
    try {
      final addresses = await InternetAddress.lookup(domain);
      print('RESOLVED $domain -> ${addresses.map((a) => a.address).join(', ')}');
    } catch (_) {}
  }
}
