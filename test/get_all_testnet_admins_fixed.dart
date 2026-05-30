import 'package:toronet/toronet.dart';
import 'package:tbank/src/core/services/toronet_client.dart';
import 'package:tbank/src/core/util/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Get all testnet admins', () async {
    await Env.init();
    final client = ToronetClient();

    try {
      final numResult = await client.roles.getNumberOfRole(roleType: RoleType.admin);
      print('Number of admins result: $numResult');
      
      final rawNumber = numResult['number'];
      final count = rawNumber is num ? rawNumber.toInt() : int.parse(rawNumber.toString());
      print('Parsed admin count: $count');
      
      for (int i = 0; i < count; i++) {
        final adminResult = await client.roles.getRoleByIndex(roleType: RoleType.admin, index: i);
        print('Admin $i: $adminResult');
      }
    } catch (e) {
      print('Error: $e');
    }
  });
}
