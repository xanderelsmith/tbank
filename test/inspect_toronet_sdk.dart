import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  final userHome = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? 'C:/Users/Xander';
  final pubCacheDir = Directory(p.join(userHome, 'AppData', 'Local', 'Pub', 'Cache', 'hosted', 'pub.dev'));
  
  if (!pubCacheDir.existsSync()) {
    print('Pub cache directory not found at ${pubCacheDir.path}');
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
  
  File? virtualApiFile;
  for (final file in dartFiles) {
    if (p.basename(file.path) == 'virtual_api.dart') {
      virtualApiFile = file;
      break;
    }
  }
  
  if (virtualApiFile != null) {
    print('\n--- virtual_api.dart file ---');
    print(virtualApiFile.readAsStringSync());
  } else {
    print('virtual_api.dart file not found.');
  }
}
