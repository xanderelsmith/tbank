import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.followRedirects = true;
  dio.options.validateStatus = (status) => true;

  try {
    print('Fetching https://testnet.toronet.org/Downloads/:');
    final response = await dio.get('https://testnet.toronet.org/Downloads/');
    print('  Status: ${response.statusCode}');
    print(
      '  Body: ${response.data.toString().substring(0, response.data.toString().length > 2000 ? 2000 : response.data.toString().length)}',
    );
  } catch (e) {
    print('  Error: $e');
  }
}
