import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.followRedirects = false;
  dio.options.validateStatus = (status) => true;

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

  final urls = [
    'https://api.connectw.com/api/payment/toro/',
    'https://api.connectw.com/api/payment/',
  ];

  for (final url in urls) {
    try {
      print('Probing: $url');
      final response = await dio.post(
        url,
        data: generateData,
        options: Options(headers: headers),
      );
      print('  Status: ${response.statusCode}');
      print('  Headers: ${response.headers.map}');
      print('  Body: ${response.data}');
    } catch (e) {
      print('  Error: $e');
    }
  }
}
