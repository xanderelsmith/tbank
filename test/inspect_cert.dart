import 'dart:io';

void main() async {
  final hostname = 'restapi.connectw.com';
  final port = 443;
  
  print('Connecting to $hostname:$port to inspect SSL certificate...');
  try {
    final socket = await SecureSocket.connect(
      hostname, 
      port, 
      onBadCertificate: (cert) {
        print('Bad Certificate Subject: ${cert.subject}');
        print('Bad Certificate Issuer: ${cert.issuer}');
        // We can't directly print SAN names easily from the Cert object in Dart API, 
        // but we can print the subject and try to see if it lists a different domain.
        return true; // bypass
      }
    );
    
    final cert = socket.peerCertificate;
    if (cert != null) {
      print('Subject: ${cert.subject}');
      print('Issuer: ${cert.issuer}');
      print('Valid From: ${cert.startValidity}');
      print('Valid To: ${cert.endValidity}');
    } else {
      print('No peer certificate found (or bypassed onBadCertificate).');
    }
    await socket.close();
  } catch (e) {
    print('Error: $e');
  }
}
