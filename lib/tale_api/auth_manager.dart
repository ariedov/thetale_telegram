import 'dart:async';

import 'package:epictale_telegram/tale_api/tale_api.dart';

class AuthManager {
  final TaleApi api;
  AuthManager(this.api);

  Timer _timer;

  Future startAuth() async {
    _timer?.cancel();
    await api.auth();

    final startTime = DateTime.now().millisecondsSinceEpoch;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final secondsDifference = (currentTime - startTime) / 1000;

      if (secondsDifference >= 600) {
        timer.cancel();
        return;
      }

      await _checkAuth();
    });
  }

  Future _checkAuth() async {
    
  }
}
