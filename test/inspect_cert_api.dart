import 'dart:io';

void main() async {
  final hostname = 'api.connectw.com';
  final port = 443;
  
  print('Connecting to $hostname:$port to inspect SSL certificate...');
  try {
    final socket = await SecureSocket.connect(
      hostname, 
      port, 
      onBadCertificate: (cert) {
        print('Bad Certificate Subject: ${cert.subject}');
        return true; // bypass
      }
    );
    
    final cert = socket.peerCertificate;
    if (cert != null) {
      print('Subject: ${cert.subject}');
      print('Issuer: ${cert.issuer}');
    } else {
      print('No peer certificate found.');
    }
    await socket.close();
  } catch (e) {
    print('Error: $e');
  }
}
