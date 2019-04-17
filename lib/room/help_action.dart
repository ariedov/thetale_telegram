import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:thetale_api/thetale_api.dart';

class HelpAction extends MultiUserAction {
  HelpAction(this._userManager, TaleApiWrapper taleApi, TelegramApi telegramApi)
      : super(taleApi, telegramApi);

  static const String name = "/help";

  final UserManager _userManager;

  @override
  Future<void> performAction({String account}) async {
    final sessions = await _userManager.readUserSession();

    if (sessions.isEmpty) {
      await trySendMessage(
          "Чтобы помочь нужно войти в аккаунт. Попробуй /auth или /start.");
      return;
    }

    final operation = await taleApi.help();
    await trySendMessage("Пытаюсь помочь!");

    Timer.periodic(Duration(seconds: 1), (timer) async {
      final status = await taleApi.checkOperation(operation.statusUrl);
      if (!status.isProcessing) {
        timer.cancel();

        final gameInfo = await taleApi.gameInfo();
        await trySendMessage(
            "${gameInfo.account.hero.base.name} рад помощи и ${gameInfo.account.hero.action?.description ?? ""}.\n${generateAccountInfo(gameInfo.account)}");
      }
    });
  }

  @override
  Future<void> performChooserAction(Map<String, String> nameSessionMap) async {
    if (nameSessionMap.isNotEmpty) {
      await trySendMessage("Выбери кому ты хочешь помочь.",
          inlineKeyboard:
              InlineKeyboard(buildAccountListAction(nameSessionMap, "/help")));
    } else {
      await trySendMessage(
          "Видимо данные об аккаунтах устарели. Попробуй перезайти через /auth");
    }
  }
}
