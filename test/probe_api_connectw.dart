import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.followRedirects = false;
  dio.options.validateStatus = (status) => true;
  dio.options.connectTimeout = const Duration(seconds: 5);

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

  final baseUrls = [
    'https://api.connectw.com/api',
    'https://api.connectw.com',
    'http://api.connectw.com/api',
    'http://api.connectw.com',
  ];

  for (final baseUrl in baseUrls) {
    for (final path in ['/payment/toro/', '/payment/toro', '/payment/', '/payment']) {
      final url = '$baseUrl$path';
      try {
        print('Probing: $url');
        final response = await dio.post(
          url,
          data: generateData,
          options: Options(headers: headers),
        );
        print('  Status: ${response.statusCode}');
        print('  Body: ${response.data}');
      } catch (e) {
        print('  Error: $e');
      }
    }
  }
}
