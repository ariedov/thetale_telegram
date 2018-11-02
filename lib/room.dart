import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/tale_api/tale_api.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';

class RoomFactory {
  Room createRoom(int chatId) {
    final userManager = MemoryUserManager(chatId);
    final taleApi = TaleApi(userManager);
    final telegramApi = TelegramApi(chatId);

    return Room(chatId, taleApi, telegramApi);
  }
}

class RoomManager {
  final Map<int, Room> _rooms = {};
  final RoomFactory _roomFactory;

  RoomManager(this._roomFactory);

  Room getRoom(int chatId) {
    if (_rooms[chatId] != null) {
      return _rooms[chatId];
    }
    return _rooms[chatId] = _roomFactory.createRoom(chatId);
  }
}

class Room {
  final int _chatId;
  final TaleApi _taleApi;
  final TelegramApi _telegramApi;

  Room(this._chatId, this._taleApi, this._telegramApi);

  /// This method will call both telegram and tale api
  void processUpdate(Update update) async {
    if (update.message.from.isBot) {
      return;
    }

    try {
      final link = await _taleApi.auth();
      await trySendMessage("Чтобы авторизоваться - перейди по ссылке ${link.authorizationPage}");
    } catch (e) {
      if (e is String) {
        await trySendMessage(e);
      }
    }
  }

  Future<Message> trySendMessage(String message) async {
    try {
      return await _telegramApi.sendMessage(message);
    } 
    catch (e) {
      print("Failed to send message");
    }
    return null;
  }
}
