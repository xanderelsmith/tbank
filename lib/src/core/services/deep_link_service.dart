import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

class DeepLinkService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  final _uriController = StreamController<Uri>.broadcast();

  Stream<Uri> get uriStream => _uriController.stream;

  DeepLinkService() {
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      // Handle the deep link if the app was started by one
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }

      // Handle deep links while the app is already running
      _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      }, onError: (err) {
        debugPrint('DeepLinkService error: $err');
      });
    } catch (e) {
      debugPrint('DeepLinkService exception: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Received Deep Link: $uri');
    _uriController.add(uri);
  }

  void dispose() {
    _linkSubscription?.cancel();
    _uriController.close();
  }
}
