import 'dart:io';

void main() async {
  final domains = [
    'connectw.com',
    'restapi.connectw.com',
    'payments.connectw.com',
    'testnet.connectw.com',
    'testnet-restapi.connectw.com',
    'testnet-api.connectw.com',
    'testnet-payments.connectw.com',
    'restapi-testnet.connectw.com',
    'api-testnet.connectw.com',
    'payments-testnet.connectw.com',
    'sandbox.connectw.com',
    'sandbox-restapi.connectw.com',
    'sandbox-payments.connectw.com',
    'dev.connectw.com',
    'dev-restapi.connectw.com',
    'dev-payments.connectw.com',
    'staging.connectw.com',
    'staging-restapi.connectw.com',
    'staging-payments.connectw.com',
    'api.connectw.com',
    'payments.toronet.org',
    'testnet.toronet.org',
    'api-testnet.toronet.org',
    'testnet-api.toronet.org',
    'restapi.toronet.org',
    'testnet-restapi.toronet.org',
  ];

  for (final domain in domains) {
    try {
      final addresses = await InternetAddress.lookup(domain);
      print('RESOLVED $domain -> ${addresses.map((a) => a.address).join(', ')}');
    } catch (e) {
      // Failed to resolve
    }
  }
}
