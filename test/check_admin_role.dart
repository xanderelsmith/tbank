import 'package:toronet/toronet.dart';
import 'package:tbank/src/core/services/toronet_client.dart';
import 'package:tbank/src/core/util/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Check admin role on-chain', () async {
    await Env.init();
    final client = ToronetClient();
    final adminAddr = Env.adminAddress;

    print('Checking admin status for $adminAddr on network: ${client.network}');
    try {
      // Check using QueryService
      final roleResult = await client.query.getAddrRole(addr: adminAddr);
      print('Query getAddrRole result: $roleResult');

      // Check using RolesService if available
      final hasRole = await client.roles.isRole(roleType: RoleType.admin, address: adminAddr);
      print('RolesService.isRole(admin): $hasRole');
    } catch (e) {
      print('Error: $e');
    }
  });
}
