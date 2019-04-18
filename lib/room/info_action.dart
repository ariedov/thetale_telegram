import 'dart:async';

import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:thetale_api/thetale_api.dart';

class InfoAction extends MultiUserAction {
  InfoAction(TaleApiWrapper taleApi, TelegramApi telegramApi)
      : super(taleApi, telegramApi);

  static const String name = "/info";

  @override
  Future<void> performAction({String account}) async {
    final info = await taleApi.gameInfo();
    await trySendMessage(
        "${info.account.hero.base.name} ${info.account.hero.action?.description ?? ""}.\n${generateAccountInfo(info.account)}");
  }

  @override
  Future<void> performChooserAction(Map<String, String> sessionNameMap) async {
    if (sessionNameMap.isNotEmpty) {
      await trySendMessage("Выбери о ком ты хочешь узнать.",
          inlineKeyboard:
              InlineKeyboard(buildAccountListAction(sessionNameMap, "/info")));
    } else {
      await trySendMessage(
          "Видимо данные об аккаунтах устарели. Попробуй перезайти через /auth");
    }
  }

  @override
  Future<void> performEmptyAction() async {
    await trySendMessage(
          "Чтобы получить информацию нужно войти в аккаунт. Попробуй /auth или /start.");
  }
}
