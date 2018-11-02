import 'dart:async';

abstract class UserManager {
  Future<void> saveUserSession(SessionInfo info);

  Future<SessionInfo> readUserSession();
}

class MemoryUserManager implements UserManager {

  final int chatId;
  final Map<int, SessionInfo> sessionInfo = {};

  MemoryUserManager(this.chatId);

  @override
  Future<SessionInfo> readUserSession() async {
    return sessionInfo[chatId];
  }

  @override
  Future<void> saveUserSession(SessionInfo info) async {
    sessionInfo[chatId] = info;
  }
}

class SessionInfo {

  final String sessionId;
  final String csrfToken;

  SessionInfo(this.sessionId, this.csrfToken);
}