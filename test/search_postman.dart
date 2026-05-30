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
  
  print('Top level items:');
  final items = data['item'] as List;
  for (final item in items) {
    print('- ${item['name']}');
  }
  
  void findWallet(dynamic item, String path) {
    if (item is Map) {
      final name = item['name'] ?? '';
      final currentPath = path.isEmpty ? name : '$path / $name';
      final isMatch = name.toString().toLowerCase().contains('wallet');
      if (item.containsKey('request') && isMatch) {
        final req = item['request'];
        print('Wallet match: $currentPath');
        print('  URL: ${req['url']?['raw'] ?? req['url']}');
      }
      if (item.containsKey('item')) {
        findWallet(item['item'], currentPath);
      }
    } else if (item is List) {
      for (final subItem in item) {
        findWallet(subItem, path);
      }
    }
  }
  
  print('\nSearching for wallet:');
  findWallet(data, '');
}
