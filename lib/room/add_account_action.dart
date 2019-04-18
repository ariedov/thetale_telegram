import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:thetale_api/thetale_api.dart';

class AddAccountAction extends TelegramAction {
  AddAccountAction(
      TaleApiWrapper taleApi, TelegramApi telegramApi)
      : super(taleApi, telegramApi);

  static const String name = "/add";

  @override
  Future<void> performAction({String account}) async {
    final info = await taleApi.apiInfo();

    final link = await taleApi.auth(
      applicationName, applicationInfo, applicationDescription);
    await trySendMessage(
      "Чтобы добавить аккаунт - перейди по ссылке ${apiUrl}${link.authorizationPage}",
      inlineKeyboard: InlineKeyboard([
        [
          InlineKeyboardButton(
              "/confirm", "/confirm ${info.sessionInfo.sessionId}")
        ]
      ]),
    );
  }
}
