import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:teledart/model.dart';
import 'package:thetale_api/thetale_api.dart';

class RemoveAccountAction extends MultiUserAction {
  RemoveAccountAction(this._userManager, ChatInfo info, TaleApiWrapper taleApi,
      TelegramWrapper telegram)
      : super(info, taleApi, telegram);

  static const String name = "/remove";

  final UserManager _userManager;

  @override
  Future<void> performAction({String account}) async {
    final sessions = await _userManager.readUserSession();

    final session = sessions.firstWhere((item) => item.sessionId == account,
        orElse: () => null);
    await _userManager.clearSession(session);

    await trySendMessage(
      "Сессия ${account} удалена.",
    );
  }

  @override
  Future<void> performChooserAction(Map<String, String> sessionNameMap) async {
    if (sessionNameMap.isNotEmpty) {
      await trySendMessage(
        "Выбери героя чтобы удалить.",
        replyMarkup: InlineKeyboardMarkup(
            inline_keyboard: buildAccountListAction(sessionNameMap, "/remove")),
      );
    } else {
      await trySendMessage(
          "Видимо данные об аккаунтах устарели. Попробуй перезайти через /auth");
    }
  }

  @override
  Future<void> performEmptyAction() {
    return null;
  }
}
