import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  // Disable automatic redirect following so we can inspect the headers of the redirect response
  dio.options.followRedirects = false;
  dio.options.validateStatus = (status) => status != null && status >= 200 && status < 400;

  final urls = [
    'https://payments.connectw.com/payment/toro/',
    'https://payments.connectw.com/payment/toro',
    'https://payments.connectw.com/payment/',
    'https://payments.connectw.com/payment',
  ];

  for (final url in urls) {
    print('Probing URL: $url');
    try {
      final response = await dio.post(
        url,
        data: {
          'op': 'generatevirtualwallet',
          'params': [
            {'name': 'address', 'value': '0x5d4f2ceed2fab22480627817ad8a1abd72507c58'},
            {'name': 'payername', 'value': 'test'},
            {'name': 'currency', 'value': 'toro'},
          ],
        },
        options: Options(
          headers: {
            'admin': '0x03c8ef05663bd8e4ad8074d650e4ccd33310cd95',
            'adminpwd': 'adminpwd',
            'Content-Type': 'application/json',
          },
        ),
      );
      print('  Status: ${response.statusCode}');
      print('  Headers: ${response.headers.map}');
    } catch (e) {
      print('  Error: $e');
    }
    print('');
  }
}
