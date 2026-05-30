import 'dart:io';

void main() async {
  final domains = [
    'restapi.testnet.toronet.org',
    'payments.testnet.toronet.org',
    'payment.testnet.toronet.org',
    'api.testnet.toronet.org',
  ];

  for (final domain in domains) {
    try {
      final addresses = await InternetAddress.lookup(domain);
      print('RESOLVED $domain -> ${addresses.map((a) => a.address).join(', ')}');
    } catch (e) {
      print('FAILED to resolve $domain');
    }
  }
}
