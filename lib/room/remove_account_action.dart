import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:thetale_api/thetale_api.dart';

class RemoveAccountAction extends MultiUserAction {
  RemoveAccountAction(
      this._userManager, TaleApiWrapper taleApi, TelegramApi telegramApi)
      : super(taleApi, telegramApi);

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
  Future<void> performChooserAction(Map<String, String> nameSessionMap) async {
    if (nameSessionMap.isNotEmpty) {
      await trySendMessage(
        "Выбери героя чтобы удалить.",
        inlineKeyboard:
            InlineKeyboard(buildAccountListAction(nameSessionMap, "/remove")),
      );
    } else {
      await trySendMessage(
          "Видимо данные об аккаунтах устарели. Попробуй перезайти через /auth");
    }
  }
}
