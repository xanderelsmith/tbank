import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.followRedirects = false;
  dio.options.validateStatus = (status) => true;
  dio.options.connectTimeout = const Duration(seconds: 5);

  final subdomains = [
    'testnet.connectw.com',
    'testnet-restapi.connectw.com',
    'testnet-api.connectw.com',
    'sandbox.connectw.com',
    'sandbox-restapi.connectw.com',
    'dev.connectw.com',
    'dev-restapi.connectw.com',
    'staging.connectw.com',
    'staging-restapi.connectw.com',
    'restapi.connectw.com',
  ];

  final adminAddress = '0x03c8ef05663bd8e4ad8074d650e4ccd33310cd95';
  final adminPassword = 'adminpwd';
  final address = '0x5d4f2ceed2fab22480627817ad8a1abd72507c58';

  final generateData = {
    'op': 'getvirtualwalletbyaddress',
    'params': [
      {'name': 'address', 'value': address},
    ],
  };

  final headers = {
    'admin': adminAddress,
    'adminpwd': adminPassword,
    'Content-Type': 'application/json',
  };

  for (final sub in subdomains) {
    // Probe the endpoint with /api/payment/ and with /payment/
    final urls = [
      'https://$sub/api/payment/',
      'https://$sub/payment/',
    ];
    for (final url in urls) {
      try {
        final response = await dio.post(
          url,
          data: generateData,
          options: Options(headers: headers),
        );
        print('POST $url: Status=${response.statusCode}, Body=${response.data}');
      } catch (e) {
        print('POST $url: Error=$e');
      }
    }
  }
}
