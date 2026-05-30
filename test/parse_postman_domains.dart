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
  
  final Set<String> domains = {};
  
  void findUrls(dynamic item) {
    if (item is Map) {
      if (item.containsKey('request')) {
        final req = item['request'];
        final urlRaw = req['url']?['raw'] ?? '';
        if (urlRaw.isNotEmpty) {
          try {
            final uri = Uri.parse(urlRaw);
            if (uri.host.isNotEmpty) {
              domains.add('${uri.scheme}://${uri.host}${uri.hasPort ? ":${uri.port}" : ""}');
            }
          } catch (_) {}
        }
      }
      if (item.containsKey('item')) {
        findUrls(item['item']);
      }
    } else if (item is List) {
      for (final subItem in item) {
        findUrls(subItem);
      }
    }
  }
  
  findUrls(data);
  print('Unique domains in Postman collection:');
  for (final domain in domains) {
    print('- $domain');
  }
}
