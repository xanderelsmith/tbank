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
      print('Number of admins: $numResult');
      
      final count = numResult['number'] ?? 0;
      for (int i = 0; i < count; i++) {
        final adminResult = await client.roles.getRoleByIndex(roleType: RoleType.admin, index: i);
        print('Admin $i: ${adminResult['addr']}');
      }
    } catch (e) {
      print('Error: $e');
    }
  });
}
