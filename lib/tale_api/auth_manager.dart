import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/tale_api/tale_api.dart';

class AuthManager {
  final TaleApi api;
  final UserManager userManager;

  final Map<String, Timer> _userTimerMap = {};

  AuthManager(this.api, this.userManager);

  Future startAuth(String username) async {
    _userTimerMap[username]?.cancel();
    await api.auth();

    _userTimerMap[username] = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (timer.tick >= 600) {
        timer.cancel();
        return;
      }

      await _checkAuth();
    });
  }

  Future _checkAuth() async {
    
  }
}
