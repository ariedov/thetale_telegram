import 'dart:async';

import 'package:epictale_telegram/tale_api/tale_api.dart';

class AuthManager {
  final TaleApi _api;

  final Map<int, Timer> _userTimerMap = {};

  AuthManager(this._api);

  Future startAuth(int chatId) async {
    _userTimerMap[chatId]?.cancel();
    await _api.auth();

    _userTimerMap[chatId] = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (timer.tick >= 600) {
        timer.cancel();
        return;
      }

      await _checkAuth();
    });
  }

  Future _checkAuth() async {
    _api.authStatus();
  }
}
