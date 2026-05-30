import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mint testnet stablecoins with owner and superadmin', () async {
    final dio = Dio();
    dio.options.followRedirects = false;
    dio.options.validateStatus = (status) => true;

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

    final targetAddress = '0x5d4f2ceed2fab22480627817ad8a1abd72507c58';
    final currencies = ['naira', 'dollar'];
    final amounts = {'naira': '500000', 'dollar': '1000'};

    for (final acc in accounts) {
      print('=== Trying ${acc['name']} ===');
      for (final curr in currencies) {
        final url = 'https://testnet.toronet.org/api/currency/$curr/ad';
        final data = {
          'op': 'importcurrency',
          'params': [
            {'name': 'admin', 'value': acc['address']},
            {'name': 'adminpwd', 'value': acc['password']},
            {'name': 'addr', 'value': targetAddress},
            {'name': 'val', 'value': amounts[curr]},
          ],
        };

        try {
          print('Minting ${amounts[curr]} $curr to $targetAddress using ${acc['name']}...');
          final response = await dio.post(
            url,
            data: data,
            options: Options(headers: {'Content-Type': 'application/json'}),
          );
          print('Response: Status=${response.statusCode}, Body=${response.data}');
        } catch (e) {
          print('Error: $e');
        }
      }
    }
  });
}
