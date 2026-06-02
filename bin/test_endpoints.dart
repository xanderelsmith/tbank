import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(
    BaseOptions(
      followRedirects: true,
      maxRedirects: 5,
      validateStatus: (status) => true,
    ),
  );

  final endpoints = [
    'https://testnet.toronet.org/api/payment/',
    'https://testnet.toronet.org/api/payment/toro/',
    'https://testnet.toronet.org/api/toro/',
    'https://testnet.toronet.org/api/virtual/',
  ];

  for (var url in endpoints) {
    try {
      print('\nTesting POST $url');
      final response = await dio.post(
        url,
        data: {
          'op': 'generatevirtualwallet',
          'params': [
            {
              'name': 'address',
              'value': '0x5d4f2ceed2fab22480627817ad8a1abd72507c58',
            },
            {'name': 'payername', 'value': 'TBank Customer'},
            {'name': 'currency', 'value': 'NGN'},
          ],
        },
        options: Options(
          headers: {
            'admin': 'some-admin',
            'adminpwd': 'password',
            'Content-Type': 'application/json',
          },
        ),
      );
      print('Status: ${response.statusCode}');
      print('Location: ${response.headers.value("location")}');
      print('Data: ${response.data}');
    } catch (e) {
      print('Error: $e');
    }
  }
}
