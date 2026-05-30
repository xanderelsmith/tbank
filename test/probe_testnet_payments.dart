import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.followRedirects = false;
  dio.options.validateStatus = (status) => true;

  final adminAddress = '0x03c8ef05663bd8e4ad8074d650e4ccd33310cd95';
  final adminPassword = 'adminpwd';
  final address = '0x5d4f2ceed2fab22480627817ad8a1abd72507c58';

  final baseUrls = [
    'https://testnet.toronet.org/api',
    'https://testnet.toronet.org',
  ];

  final headers = {
    'admin': adminAddress,
    'adminpwd': adminPassword,
    'Content-Type': 'application/json',
  };

  // 1. Test generatevirtualwallet
  print('=== Probing generatevirtualwallet ===');
  final generateData = {
    'op': 'generatevirtualwallet',
    'params': [
      {'name': 'address', 'value': address},
      {'name': 'payername', 'value': 'test'},
      {'name': 'currency', 'value': 'toro'},
    ],
  };

  for (final baseUrl in baseUrls) {
    for (final path in ['/payment/toro/', '/payment/toro', '/payment/', '/payment']) {
      final url = '$baseUrl$path';
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

  // 2. Test getvirtualwalletbyaddress
  print('\n=== Probing getvirtualwalletbyaddress ===');
  final getData = {
    'op': 'getvirtualwalletbyaddress',
    'params': [
      {'name': 'address', 'value': address},
    ],
  };

  for (final baseUrl in baseUrls) {
    for (final path in ['/payment/toro/', '/payment/toro', '/payment/', '/payment']) {
      final url = '$baseUrl$path';
      try {
        final response = await dio.post(
          url,
          data: getData,
          options: Options(headers: headers),
        );
        print('POST $url: Status=${response.statusCode}, Body=${response.data}');
      } catch (e) {
        print('POST $url: Error=$e');
      }
    }
  }
}
