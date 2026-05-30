import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mint testnet stablecoins', () async {
    final dio = Dio();
    dio.options.followRedirects = false;
    dio.options.validateStatus = (status) => true;

    final adminAddress = '0xea45bcd1b04233f9240c01d52f773b832704fed0';
    final adminPassword = 'toronet';
    final targetAddress = '0x5d4f2ceed2fab22480627817ad8a1abd72507c58';

    final currencies = ['naira', 'dollar'];
    final amounts = {'naira': '500000', 'dollar': '1000'};

    for (final curr in currencies) {
      final url = 'https://testnet.toronet.org/api/currency/$curr/ad';
      final data = {
        'op': 'importcurrency',
        'params': [
          {'name': 'admin', 'value': adminAddress},
          {'name': 'adminpwd', 'value': adminPassword},
          {'name': 'addr', 'value': targetAddress},
          {'name': 'val', 'value': amounts[curr]},
        ],
      };

      try {
        print('Minting ${amounts[curr]} $curr to $targetAddress...');
        final response = await dio.post(
          url,
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}),
        );
        print('Response for $curr: Status=${response.statusCode}, Body=${response.data}');
      } catch (e) {
        print('Error minting $curr: $e');
      }
    }
  });
}
