import 'dart:async';

import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:teledart/model.dart';
import 'package:thetale_api/thetale_api.dart';

class ConfirmAuthAction extends TelegramAction {
  ConfirmAuthAction(
      MessageInfo messageInfo, TaleApiWrapper taleApi, TelegramWrapper telegram)
      : super(messageInfo, taleApi, telegram);

  static const String name = "/confirm";

  @override
  Future<void> performAction({String account}) async {
    final status = await taleApi.authStatus();

    if (status.data.isAccepted) {
      await tryUpdateMessageMarkup(InlineKeyboardMarkup());
      await tryUpdateMessageText("Ну привет, ${status.data.accountName}.");

      final gameInfo = await taleApi.gameInfo();
      await trySendMessage(
          """${gameInfo.account.hero.base.name} уже заждался.\n${generateAccountInfo(gameInfo.account)}""",
          replyMarkup: ReplyKeyboardMarkup(keyboard: [
            [KeyboardButton(text: "/help")],
            [KeyboardButton(text: "/info")],
          ]));
    } else {
      await trySendMessage("Тебе стоит попытаться еще раз.");
    }
  }
}
