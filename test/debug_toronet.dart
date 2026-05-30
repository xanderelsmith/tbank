import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  final adminAddress = '0x03c8ef05663bd8e4ad8074d650e4ccd33310cd95';
  final adminPassword = 'adminpwd';
  final address = '0x5d4f2ceed2fab22480627817ad8a1abd72507c58';

  final urls = [
    'https://payments.connectw.com/api/payment/',
    'https://payments.connectw.com/api/payment',
    'https://payments.connectw.com/api/payment/toro/',
    'https://payments.connectw.com/api/payment/toro',
  ];

  final headers = {
    'admin': adminAddress,
    'adminpwd': adminPassword,
    'Content-Type': 'application/json',
  };

  final data = {
    'op': 'getvirtualwalletbyaddress',
    'params': [
      {'name': 'address', 'value': address},
    ],
  };

  for (final url in urls) {
    for (final method in ['POST', 'GET']) {
      print('--- Request: $method to $url ---');
      try {
        final response = await dio.request(
          url,
          data: method == 'POST' ? data : null,
          options: Options(
            method: method,
            headers: headers,
            validateStatus: (status) => true,
          ),
        );
        print('Status: ${response.statusCode}');
        print('Body: ${response.data}');
      } catch (e) {
        print('Error: $e');
      }
      print('');
    }
  }
}
