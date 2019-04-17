import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:thetale_api/thetale_api.dart';

class MongoUserManager implements UserManager {
  MongoUserManager(this.chatId, this.db);

  final int chatId;
  final Db db;

  @override
  Future<List<SessionInfo>> readUserSession() async {
    final rooms = db.collection("rooms");
    final data = await rooms.find(where.eq("chat_id", chatId)).toList();

    return data
        .map((item) => SessionInfo(
              item["session_id"] as String,
              item["csrf_token"] as String,
            ))
        .toList();
  }

  @override
  Future<void> updateUserSession(SessionInfo info) async {
    final rooms = db.collection("rooms");
    final session = await rooms.findOne(where.eq("chat_id", chatId).and(where
        .eq("session_id", info.sessionId)
        .or(where.eq("csrf_token", info.csrfToken))));

    session["session_id"] = info.sessionId;
    session["csrf_token"] = info.csrfToken;

    await rooms.save(session);
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

  @override
  Future<void> addUserSession(SessionInfo info) async {
    final rooms = db.collection("rooms");

    await rooms.insert({
      "chat_id": chatId,
      "session_id": info.sessionId,
      "csrf_token": info.csrfToken
    });
  }
}
