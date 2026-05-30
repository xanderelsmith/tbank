import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.followRedirects = false;
  dio.options.validateStatus = (status) => true;

  try {
    final response = await dio.get('https://payments.toronet.org');
    print('GET https://payments.toronet.org:');
    print('  Status: ${response.statusCode}');
    print('  Headers: ${response.headers.map}');
    print('  Body: ${response.data.toString().substring(0, response.data.toString().length > 300 ? 300 : response.data.toString().length)}');
  } catch (e) {
    print('GET Error: $e');
  }

  // Also print where POST https://payments.toronet.org/payment/toro redirects to
  try {
    final response = await dio.post('https://payments.toronet.org/payment/toro');
    print('\nPOST https://payments.toronet.org/payment/toro:');
    print('  Status: ${response.statusCode}');
    print('  Headers: ${response.headers.map}');
  } catch (e) {
    print('POST Error: $e');
  }
}
