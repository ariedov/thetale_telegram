import 'dart:async';
import 'package:thetale_api/thetale_api.dart';

abstract class UserManager {
  Future<void> updateUserSession(SessionInfo info);

  Future<void> addUserSession(SessionInfo info);

  Future<List<SessionInfo>> readUserSession();

  Future<void> clearSession(SessionInfo info);

  Future<void> clearAll();
}

class UserSessionStorage extends SessionStorage {
  UserSessionStorage(this.userManager, this.sessionInfo);

  final UserManager userManager;
  final SessionInfo sessionInfo;

  @override
  Future<void> addSession(SessionInfo sessionInfo) async {
    await userManager.addUserSession(sessionInfo);
  }

  @override
  Future<SessionInfo> readSession() async {
    return sessionInfo;
  }

  @override
  Future<void> updateSession(SessionInfo sessionInfo) async {
    await userManager.updateUserSession(sessionInfo);
  }
}