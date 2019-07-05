import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/persistence/user_manager_provider.dart';
import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/room/action_router.dart';
import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:teledart/model.dart';
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
    final actionRouter = ActionRouter(userManager, taleApi);

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

  Future processMessage(MessageInfo messageInfo, TelegramWrapper telegram, Message message) async {
    try {
      await _processText(messageInfo, telegram, message.text);
    } catch (e) {
      print(e);
    }
  }

  Future processCallbackQuery(MessageInfo messageInfo, TelegramWrapper telegram, CallbackQuery callbackQuery) async {
    try {
      await _processText(messageInfo, telegram, callbackQuery.data);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _processText(MessageInfo messageInfo, TelegramWrapper telegram, String message) async {
    final actionAccount = getActionAccountFromMessage(message.trim());

    final action = _actionRouter.route(messageInfo, telegram, actionAccount.action);
    final sessions = await _userManager.readUserSession() ?? [];

    final accountSession = sessions.firstWhere(
        (session) => session.sessionId == actionAccount.account,
        orElse: () => null);
    if (action is MultiUserAction) {
      if (sessions.isEmpty) {
        await action.performEmptyAction();
        return;
      }

      if (accountSession == null && sessions.length > 1) {
        final sessionNameMap = await _getSessionNameMap(sessions, _taleApi);
        await action.performChooserAction(sessionNameMap);
      } else {
        final resultSession = accountSession ?? sessions[0];
        await applyAction(resultSession, action, resultSession.sessionId);
      }
    } else {
      final resultSession = accountSession ?? (sessions.isNotEmpty ? sessions[0] : null);
      await applyAction(resultSession, action, resultSession?.sessionId);
    }
  }

  Future<void> applyAction(
      SessionInfo session, TelegramAction action, String account) async {
    _taleApi.setStorage(UserSessionStorage(_userManager, session));

    await action.apply(account: account);
  }

  Future<Map<String, String>> _getSessionNameMap(
      List<SessionInfo> sessions, TaleApiWrapper taleApi,
      {bool allowUnauthorized = false}) async {
    final sessionNameMap = <String, String>{};

    for (final session in sessions) {
      taleApi.setStorage(ReadonlySessionStorage(session));
      final info = await taleApi.gameInfo();

      if (info.account != null || allowUnauthorized) {
        sessionNameMap[session.sessionId] = info.account?.hero?.base?.name ?? session.sessionId;
      }
    }

    return sessionNameMap;
  }
}

ActionAccount getActionAccountFromMessage(String message) {
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
