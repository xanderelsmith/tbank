import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

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

  final paths = [
    '/api/payment/testnet/',
    '/api/payment/toro/testnet/',
    '/api/testnet/payment/toro/',
    '/api/testnet/payment/',
    '/testnet/api/payment/toro/',
    '/testnet/api/payment/',
    '/api/payment/toro-testnet/',
    '/api/payment-testnet/toro/',
  ];

  for (final path in paths) {
    final url = 'https://restapi.connectw.com$path';
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
