import 'dart:async';

import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:teledart/model.dart';
import 'package:thetale_api/thetale_api.dart';

class HelpAction extends MultiUserAction {
  HelpAction(
      ChatInfo chatInfo, TaleApiWrapper taleApi, TelegramWrapper telegram)
      : super(chatInfo, taleApi, telegram);

  static const String name = "/help";

  @override
  Future<void> performAction({String account}) async {
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
  Future<void> performChooserAction(Map<String, String> sessionNameMap) async {
    if (sessionNameMap.isNotEmpty) {
      await trySendMessage("Выбери кому ты хочешь помочь.",
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
        "Чтобы помочь нужно войти в аккаунт. Попробуй /auth или /start.");
  }
}
