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

  final accounts = [
    {
      'name': 'owner',
      'address': '0x43F78b342084e370f10e0Cd07d56d95c1728C9D4',
      'password': 'toronet'
    },
    {
      'name': 'superadmin',
      'address': '0xd81f3d3ec6eedbc1e1d6245d1adfff5e492bb787',
      'password': 'toronet'
    }
  ];

  final userAddress = '0x5d4f2ceed2fab22480627817ad8a1abd72507c58';

  final generateData = {
    'op': 'generatevirtualwallet',
    'params': [
      {'name': 'address', 'value': userAddress},
      {'name': 'payername', 'value': 'TBank Test Client'},
      {'name': 'currency', 'value': 'NGN'},
    ],
  };

  final url = 'https://restapi.connectw.com/api/payment/toro/';

  for (final acc in accounts) {
    final headers = {
      'admin': acc['address']!,
      'adminpwd': acc['password']!,
      'Content-Type': 'application/json',
    };

    try {
      print('Testing generatevirtualwallet on $url with ${acc['name']} credentials...');
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
}
