import 'dart:async';

final class AuthEventBus {
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get authStateStream => _controller.stream;

  void emitAuthenicated() {
    _controller.add(true);
  }

  void emitUnauthenticated() {
    _controller.add(false);
  }
}
