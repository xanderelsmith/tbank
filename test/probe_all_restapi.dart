import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

// Probe all potential paths and configurations on restapi.connectw.com
void main() async {
  final dio = Dio();
  dio.options.followRedirects = false;
  dio.options.validateStatus = (status) => true;

  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    },
  );

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
    'https://restapi.connectw.com',
    'http://restapi.connectw.com',
  ];

  final paths = [
    '/api/payment/toro/',
    '/api/payment/toro',
    '/api/payment/',
    '/api/payment',
    '/payment/toro/',
    '/payment/toro',
    '/payment/',
    '/payment',
  ];

  for (final baseUrl in baseUrls) {
    for (final path in paths) {
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
