import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.followRedirects = false;
  dio.options.validateStatus = (status) => true;

  try {
    final response = await dio.get('https://connectworld.com');
    print('GET https://connectworld.com: Status=${response.statusCode}, Headers=${response.headers.map}');
  } catch (e) {
    print('GET Error: $e');
  }

  try {
    final response = await dio.get('https://restapi.connectworld.com');
    print('GET https://restapi.connectworld.com: Status=${response.statusCode}, Headers=${response.headers.map}');
  } catch (e) {
    print('GET Error: $e');
  }
}
