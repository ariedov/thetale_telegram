import 'dart:async';

import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:teledart/model.dart';
import 'package:thetale_api/thetale_api.dart';

class InfoAction extends MultiUserAction {
  InfoAction(
      MessageInfo messageInfo, TaleApiWrapper taleApi, TelegramWrapper telegram)
      : super(messageInfo, taleApi, telegram);

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
          replyMarkup: InlineKeyboardMarkup(
              inline_keyboard: buildAccountListAction(sessionNameMap, name)));
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
