import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  final userHome = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? 'C:/Users/Xander';
  final pubCacheDir = Directory(p.join(userHome, 'AppData', 'Local', 'Pub', 'Cache', 'hosted', 'pub.dev'));
  
  if (!pubCacheDir.existsSync()) {
    print('Pub cache directory not found');
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
  
  print('Searching Toronet SDK for WebSocket/Socket/Stream/Subscription references...');
  int matchCount = 0;
  for (final file in dartFiles) {
    final content = file.readAsStringSync();
    final relativePath = p.relative(file.path, from: libDir.path);
    
    if (content.contains('WebSocket') || 
        content.contains('websocket') || 
        content.contains('Socket') || 
        content.contains('socket') ||
        content.contains('subscribe') ||
        content.contains('EventStream')) {
      print('Match found in: $relativePath');
      matchCount++;
    }
  }
  print('Total matches found: $matchCount');
}
