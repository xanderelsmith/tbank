import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.followRedirects = false;
  dio.options.validateStatus = (status) => true;

  try {
    print('Probing https://testnet.toronet.org/api/blockchain:');
    final response = await dio.get('https://testnet.toronet.org/api/blockchain');
    print('  Status: ${response.statusCode}');
    print('  Headers: ${response.headers.map}');
    print('  Body: ${response.data}');
  } catch (e) {
    print('  Error: $e');
  }

  try {
    print('\nProbing https://testnet.toronet.org/blockchain:');
    final response = await dio.get('https://testnet.toronet.org/blockchain');
    print('  Status: ${response.statusCode}');
    print('  Headers: ${response.headers.map}');
    print('  Body: ${response.data.toString().substring(0, response.data.toString().length > 200 ? 200 : response.data.toString().length)}');
  } catch (e) {
    print('  Error: $e');
  }
}
