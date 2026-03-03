import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locket/core/injection.dart';

final deeplinkServiceProvider = Provider<DeeplinkService>((ref) {
  final router = ref.read(routerProvider);
  return DeeplinkService(router);
});

class DeeplinkService {
  final GoRouter _router;
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  DeeplinkService(this._router);

  void init() async {
    // Xử lý deep link khi app đang mở
    _subscription = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });

    // Lấy deep link đầu tiên nếu app được mở từ deeplink
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (e) {
      print('DeeplinkService init error: $e');
    }
  }

  void _handleUri(Uri uri) {
    if (uri.scheme == 'locket' && uri.host == 'app') {
      if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'add-friend') {
        final shareCode = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        if (shareCode != null && shareCode.isNotEmpty) {
          // Trì hoãn một chút để đảm bảo router sẵn sàng
          Future.microtask(() {
            _router.push('/add-friend/$shareCode');
          });
        }
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
