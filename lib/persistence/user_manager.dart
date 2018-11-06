import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';

abstract class UserManager {
  Future<void> saveUserSession(SessionInfo info, {bool isAuthorized});

  Future<SessionInfo> readUserSession();

  Future<void> setAuthorized({bool authorized});

  Future<bool> isAuthorized();
}

class MemoryUserManager implements UserManager {
  final int chatId;
  final Map<int, SessionInfo> sessionInfo = {};
  bool _isAuthorized = false;

  MemoryUserManager(this.chatId);

  @override
  Future<SessionInfo> readUserSession() async {
    return sessionInfo[chatId];
  }

  @override
  Future<void> saveUserSession(SessionInfo info, {bool isAuthorized}) async {
    sessionInfo[chatId] = info;
    _isAuthorized = isAuthorized;
  }

  @override
  Future<void> setAuthorized({bool authorized}) async {
    _isAuthorized = authorized;
  }

  @override
  Future<bool> isAuthorized() async {
    return _isAuthorized;
  }
}

class MongoUserManager implements UserManager {
  final int chatId;
  final Db db;

  MongoUserManager(this.chatId, this.db);

  @override
  Future<SessionInfo> readUserSession() async {
    final rooms = db.collection("rooms");
    final data = await rooms.findOne(where.eq("chat_id", chatId));

    return SessionInfo(
      data["session_id"] as String,
      data["csrf_token"] as String,
    );
  }

  @override
  Future<void> saveUserSession(SessionInfo info, {bool isAuthorized = true}) async {
    final rooms = db.collection("rooms");
    await rooms.remove(where.eq("chat_id", chatId));
    await rooms.insert({
      "chat_id": chatId,
      "session_id": info.sessionId,
      "csrf_token": info.csrfToken,
      "is_authorized": isAuthorized
    });
  }

  @override
  Future<void> setAuthorized({bool authorized}) async {
    final rooms = db.collection("rooms");
    final room = await rooms.findOne(where.eq("chat_id", chatId));
    if (room != null) {
      room["is_authorized"] = authorized;
      await rooms.save(room);
    } else {
      await rooms.insert({
        "chat_id": chatId,
        "is_authorized": authorized
      });
    }
  }

  @override
  Future<bool> isAuthorized() async {
    final rooms = db.collection("rooms");
    final room = await rooms.findOne(where.eq("chat_id", chatId));
    return room != null && room["is_authorized"] as bool;
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
