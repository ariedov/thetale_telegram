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
  UserSessionStorage(this.userManager, this._sessionInfo);

  final UserManager userManager;

  SessionInfo _sessionInfo;

  @override
  Future<void> addSession(SessionInfo sessionInfo) async {
    _sessionInfo = sessionInfo;
    await userManager.addUserSession(sessionInfo);
  }

  @override
  Future<SessionInfo> readSession() async {
    return _sessionInfo;
  }

  @override
  Future<void> updateSession(SessionInfo sessionInfo) async {
    _sessionInfo = SessionInfo(sessionInfo.sessionId ?? _sessionInfo.sessionId,
        sessionInfo.csrfToken ?? _sessionInfo.csrfToken);
    await userManager.updateUserSession(_sessionInfo);
  }
}

class ReadonlySessionStorage extends SessionStorage {
  ReadonlySessionStorage(this.info);

  final SessionInfo info;

  @override
  Future<void> addSession(SessionInfo sessionInfo) {
    throw "Cannot add session";
  }

  @override
  Future<SessionInfo> readSession() async {
    return info;
  }

  @override
  Future<void> updateSession(SessionInfo sessionInfo) {
    throw "Cannot update session";
  }
}
