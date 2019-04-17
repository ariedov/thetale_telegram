import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:thetale_api/thetale_api.dart';

class RequestAuthAction extends TelegramAction {
  RequestAuthAction(
      this._userManager, TaleApiWrapper taleApi, TelegramApi telegramApi)
      : super(taleApi, telegramApi);

  static const String name = "/auth";

  final UserManager _userManager;

  @override
  Future<void> performAction({String account}) async {
    await _userManager.clearAll();
    final info = await taleApi.apiInfo();

    final link = await taleApi.auth(
        applicationName, applicationInfo, applicationDescription);
    await trySendMessage(
      "Чтобы авторизоваться - перейди по ссылке ${apiUrl}${link.authorizationPage}",
      inlineKeyboard: InlineKeyboard([
        [
          InlineKeyboardButton(
              "/confirm", "/confirm ${info.sessionInfo.sessionId}")
        ]
      ]),
    );
  }
}
