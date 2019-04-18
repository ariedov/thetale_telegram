import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/persistence/user_manager_provider.dart';
import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/room/action_router.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:thetale_api/thetale_api.dart';

const String apiUrl = "https://the-tale.org";
const String applicationId = "epic_tale_telegram";
const String appVersion = "0.0.1";

class RoomFactory {
  RoomFactory(this._userProvider);

  final UserManagerProvider _userProvider;

  Room createRoom(int chatId) {
    final userManager = _userProvider.getUserManager(chatId);
    final taleApi = WrapperBuilder().build(apiUrl, applicationId, appVersion);
    final telegramApi = TelegramApi(chatId);
    final actionRouter = ActionRouter(userManager, taleApi, telegramApi);

    return Room(userManager, taleApi, actionRouter);
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
  Room(this._userManager, this._taleApi, this._actionRouter);

  final UserManager _userManager;
  final TaleApiWrapper _taleApi;
  final ActionRouter _actionRouter;

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
    final sessions = await _userManager.readUserSession() ?? [];

    if (action is MultiUserAction) {
      if (sessions.isEmpty) {
        await action.performEmptyAction();
        return;
      }

      final accountSession = sessions.firstWhere(
          (session) => session.sessionId == actionAccount.account,
          orElse: () => null);
      if (accountSession == null && sessions.length > 1) {
        final nameSessionMap = await _getNameSessionMap(sessions, _taleApi);
        await action.performChooserAction(nameSessionMap);
      } else {
        final resultSession = accountSession ?? sessions[0]; 
        await applyAction(resultSession, action, resultSession.sessionId);
      }
    } else {
      final resultSession = sessions.isNotEmpty ? sessions[0] : null;
      await applyAction(
          resultSession,
          action,
          resultSession?.sessionId);
    }
  }

  Future<void> applyAction(
      SessionInfo session, TelegramAction action, String account) async {
    _taleApi.setStorage(UserSessionStorage(_userManager, session));

    await action.apply(account: account);
  }

  Future<Map<String, String>> _getNameSessionMap(
      List<SessionInfo> sessions, TaleApiWrapper taleApi,
      {bool allowUnauthorized = false}) async {
    final nameSessionMap = <String, String>{};

    for (final session in sessions) {
      final info = await taleApi.gameInfo();

      if (info.account != null || allowUnauthorized) {
        nameSessionMap[info.account?.hero?.base?.name ?? session.sessionId] =
            session.sessionId;
      }
    }

    return nameSessionMap;
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
