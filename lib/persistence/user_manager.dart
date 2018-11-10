import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';

abstract class UserManager {
  Future<void> saveUserSession(SessionInfo info);

  Future<List<SessionInfo>> readUserSession();

  Future<void> clearSession(SessionInfo info);

  Future<void> clearAll();
}

class MemoryUserManager implements UserManager {
  final int chatId;
  final Map<int, List<SessionInfo>> sessionInfo = {};

  MemoryUserManager(this.chatId);

  @override
  Future<List<SessionInfo>> readUserSession() async {
    return sessionInfo[chatId];
  }

  @override
  Future<void> saveUserSession(SessionInfo info) async {
    sessionInfo[chatId].add(info);
  }

  @override
  Future<void> clearSession(SessionInfo info) async {}

  @override
  Future<void> clearAll() async {
    sessionInfo[chatId] = [];
  }
}

class MongoUserManager implements UserManager {
  final int chatId;
  final Db db;

  MongoUserManager(this.chatId, this.db);

  @override
  Future<List<SessionInfo>> readUserSession() async {
    final rooms = db.collection("rooms");
    final data = await rooms.findOne(where.eq("chat_id", chatId));

    return [
      SessionInfo(
        data["session_id"] as String,
        data["csrf_token"] as String,
      )
    ];
  }

  @override
  Future<void> saveUserSession(SessionInfo info) async {
    final rooms = db.collection("rooms");
    final session = await rooms.findOne(where.eq("chat_id", chatId).and(where
        .eq("session_id", info.sessionId)
        .or(where.eq("csrf_token", info.csrfToken))));

    if (session != null) {
      session["session_id"] = info.sessionId;
      session["csrf_token"] = info.csrfToken;

      await rooms.save(session);
      return;
    }

    await rooms.insert({
      "chat_id": chatId,
      "session_id": info.sessionId,
      "csrf_token": info.csrfToken
    });
  }

  @override
  Future<void> clearAll() async {
    final rooms = db.collection("rooms");
    await rooms.remove(where.eq("chat_id", chatId));
  }

  @override
  Future<void> clearSession(SessionInfo info) async {
    final rooms = db.collection("rooms");
    await rooms.remove(where
        .eq("chat_id", chatId)
        .eq("csrf_token", info.csrfToken)
        .eq("session_id", info.sessionId));
  }
}

class SessionInfo {
  final String sessionId;
  final String csrfToken;

  SessionInfo(this.sessionId, this.csrfToken);
}

class UserManagerProvider {
  final Db _db;

  UserManagerProvider(this._db);

  UserManager getUserManager(int chatId) {
    return MongoUserManager(chatId, _db);
  }
}
