import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test auto-enrollment of recipient address on Testnet', () async {
    final dio = Dio();
    final url = 'https://testnet.toronet.org/api/currency/dollar/ad';

    final adminAddress = '0x43F78b342084e370f10e0Cd07d56d95c1728C9D4';
    final adminPassword = 'toronet';
    final targetAddress = '0x0F9922aaA6461fd0319624a26e1d852c90CF233c';

    try {
      print('Enrolling $targetAddress in dollar contract...');
      final response = await dio.post(
        url,
        data: {
          'op': 'enroll',
          'params': [
            {'name': 'admin', 'value': adminAddress},
            {'name': 'adminpwd', 'value': adminPassword},
            {'name': 'addr', 'value': targetAddress},
          ],
        },
      );
      print('Response: ${response.data}');
    } catch (e) {
      print('Error: $e');
    }
  });
}
