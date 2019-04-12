import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room/action_router.dart';
import 'package:epictale_telegram/tale_api/tale_api.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';

class RoomFactory {

  RoomFactory(this._userProvider);

  final UserManagerProvider _userProvider;

  Room createRoom(int chatId) {
    final userManager = _userProvider.getUserManager(chatId);
    final taleApi = TaleApi();
    final telegramApi = TelegramApi(chatId);

    return Room(userManager, taleApi, telegramApi);
  }
}

class RoomManager {

  RoomManager(this._roomFactory);

  final Map<int, Room> _rooms = {};
  final RoomFactory _roomFactory;

  Room getRoom(int chatId) {
    if (_rooms[chatId] != null) {
      return _rooms[chatId];
    }
    return _rooms[chatId] = _roomFactory.createRoom(chatId);
  }
}

class Room {
  
  Room(this._userManager, this._taleApi, this._telegramApi) {
    _actionRouter = ActionRouter(_userManager, _taleApi, _telegramApi);
  }

  final UserManager _userManager;
  final TaleApi _taleApi;
  final TelegramApi _telegramApi;

  ActionRouter _actionRouter;

  /// This method will call both telegram and tale api
  Future processUpdate(Update update) async {
    try {
      String message;
      if (update.callbackQuery != null) {
        message = update.callbackQuery.data;
      } else {
        message = update.message.text;
      }
      await _processMessage(message);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _processMessage(String message) async {
    final actionAccount = processMessage(message.trim());

    final action = _actionRouter.route(actionAccount.action);
    await action.apply(account: actionAccount.account);
  }
}

ActionAccount processMessage(String message) {
  final exp = RegExp(r"(\/\w+)\s*(\w+)*");
  final groups = exp.firstMatch(message);
  
  return ActionAccount(
    groups.group(1),
    groups.group(2),
  );
}

class ActionAccount {
  ActionAccount(this.action, this.account);

  final String action;
  final String account;
}
