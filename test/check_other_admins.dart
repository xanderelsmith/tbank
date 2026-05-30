import 'package:toronet/toronet.dart';
import 'package:tbank/src/core/services/toronet_client.dart';
import 'package:tbank/src/core/util/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Check different addresses roles', () async {
    await Env.init();
    final client = ToronetClient();

    final addresses = [
      '0x43F78b342084e370f10e0Cd07d56d95c1728C9D4',
      '0xd81f3d3ec6eedbc1e1d6245d1adfff5e492bb787',
      '0xea45bcd1b04233f9240c01d52f773b832704fed0',
      '0x03c8ef05663bd8e4ad8074d650e4ccd33310cd95',
    ];

    for (final addr in addresses) {
      try {
        final roleResult = await client.query.getAddrRole(addr: addr);
        print('Address: $addr, Role: ${roleResult['role']}, Message: ${roleResult['message']}');
      } catch (e) {
        print('Address: $addr, Error: $e');
      }
    }
  });
}
