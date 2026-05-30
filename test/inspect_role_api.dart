import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  final userHome = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? 'C:/Users/Xander';
  final pubCacheDir = Directory(p.join(userHome, 'AppData', 'Local', 'Pub', 'Cache', 'hosted', 'pub.dev'));
  
  if (!pubCacheDir.existsSync()) {
    return;
  }
  
  final entities = pubCacheDir.listSync();
  List<Directory> toronetDirs = [];
  for (final entity in entities) {
    if (entity is Directory && p.basename(entity.path).startsWith('toronet-')) {
      toronetDirs.add(entity);
    }
  }
  
  toronetDirs.sort((a, b) => b.path.compareTo(a.path));
  final toronetDir = toronetDirs.first;
  final libDir = Directory(p.join(toronetDir.path, 'lib'));
  final dartFiles = libDir.listSync(recursive: true).where((e) => e is File && e.path.endsWith('.dart')).cast<File>();
  
  File? queryImpl;
  File? rolesImpl;
  for (final file in dartFiles) {
    if (p.basename(file.path) == 'query_service_impl.dart') {
      queryImpl = file;
    }
    if (p.basename(file.path) == 'roles_service_impl.dart') {
      rolesImpl = file;
    }
  }
  
  if (queryImpl != null) {
    print('\n--- query_service_impl.dart file ---');
    final lines = queryImpl.readAsLinesSync();
    int idx = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('getAddrRole')) {
        idx = i;
        break;
      }
    }
    if (idx != -1) {
      for (int i = idx; i < idx + 10 && i < lines.length; i++) {
        print('$i: ${lines[i]}');
      }
    }
  }
  
  if (rolesImpl != null) {
    print('\n--- roles_service_impl.dart file ---');
    final lines = rolesImpl.readAsLinesSync();
    int idx = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('class RolesServiceImpl')) {
        idx = i;
        break;
      }
    }
    if (idx != -1) {
      for (int i = idx; i < idx + 40 && i < lines.length; i++) {
        print('$i: ${lines[i]}');
      }
    }
  }
}
