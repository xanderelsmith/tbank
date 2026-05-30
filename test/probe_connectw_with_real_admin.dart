import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void main() async {
  final dio = Dio();
  dio.options.followRedirects = false;
  dio.options.validateStatus = (status) => true;

  // Bypass SSL certificate verification
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    },
  );

  final adminAddress = '0xea45bcd1b04233f9240c01d52f773b832704fed0';
  final adminPassword = 'toronet';
  final userAddress = '0x5d4f2ceed2fab22480627817ad8a1abd72507c58';

  final generateData = {
    'op': 'generatevirtualwallet',
    'params': [
      {'name': 'address', 'value': userAddress},
      {'name': 'payername', 'value': 'TBank Test Client'},
      {'name': 'currency', 'value': 'NGN'},
    ],
  };

  final headers = {
    'admin': adminAddress,
    'adminpwd': adminPassword,
    'Content-Type': 'application/json',
  };

  final url = 'https://restapi.connectw.com/api/payment/toro/';

  try {
    print('Testing generatevirtualwallet on $url with testnet admin credentials...');
    final response = await dio.post(
      url,
      data: generateData,
      options: Options(headers: headers),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.data}');
  } catch (e) {
    print('Error: $e');
  }
}
