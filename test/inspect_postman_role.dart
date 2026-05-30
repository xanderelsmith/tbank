import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('C:/Users/Xander/.gemini/antigravity/brain/b95e90da-c1d9-4924-8512-cac87edbaeb8/.system_generated/steps/382/content.md');
  if (!await file.exists()) {
    print('File not found!');
    return;
  }
  
  final lines = await file.readAsLines();
  int jsonStart = -1;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].trim() == '{') {
      jsonStart = i;
      break;
    }
  }
  
  final jsonString = lines.sublist(jsonStart).join('\n');
  final data = jsonDecode(jsonString);
  
  void findRoleRequests(dynamic item, String path) {
    if (item is Map) {
      final name = item['name'] ?? '';
      final currentPath = path.isEmpty ? name : '$path / $name';
      if (currentPath.contains('/role')) {
        if (item.containsKey('request')) {
          final req = item['request'];
          print('Request: $currentPath');
          print('  URL: ${req['url']?['raw'] ?? req['url']}');
          if (req['body'] != null) {
            print('  Body Mode: ${req['body']['mode']}');
            print('  Body Raw: ${req['body']['raw']}');
          }
        }
      }
      if (item.containsKey('item')) {
        findRoleRequests(item['item'], currentPath);
      }
    } else if (item is List) {
      for (final subItem in item) {
        findRoleRequests(subItem, path);
      }
    }
  }
  
  findRoleRequests(data, '');
}
