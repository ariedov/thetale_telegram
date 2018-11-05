import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/tale_api/tale_api.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';

class RoomFactory {
  final UserManagerProvider _userProvider;
  RoomFactory(this._userProvider);

  Room createRoom(int chatId) {
    final userManager = _userProvider.getUserManager(chatId);
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
  
  ActionRouter _actionRouter;

  Room(this._chatId, this._taleApi, this._telegramApi) {
    _actionRouter = ActionRouter(_taleApi, _telegramApi);
  }

  /// This method will call both telegram and tale api
  Future processUpdate(Update update) async {
    if (update.message.from.isBot) {
      return;
    }

    try {
      await _processMessage(update.message.text);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _processMessage(String message) async {
    final action = _actionRouter.route(message);
    await action.performAction();
  }
}
