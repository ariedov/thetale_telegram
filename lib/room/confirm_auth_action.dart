import 'dart:async';

import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:thetale_api/thetale_api.dart';

class ConfirmAuthAction extends TelegramAction {
  ConfirmAuthAction(
      TaleApiWrapper taleApi, TelegramApi telegramApi)
      : super(taleApi, telegramApi);

  static const String name = "/confirm";

  @override
  Future<void> performAction({String account}) async {
    final status = await taleApi.authStatus();

    if (status.data.isAccepted) {
      await trySendMessage("Ну привет, ${status.data.accountName}.",
          keyboard: ReplyKeyboard([
            ["/help"],
            ["/info"],
          ]));

      // TODO: remove "/confirm" button from previous message

      final gameInfo = await taleApi.gameInfo();
      await trySendMessage(
          """${gameInfo.account.hero.base.name} уже заждался.\n${generateAccountInfo(gameInfo.account)}""");
    } else {
      await trySendMessage("Тебе стоит попытаться еще раз.");
    }
  }
}