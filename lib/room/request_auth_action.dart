import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:teledart/model.dart';
import 'package:thetale_api/thetale_api.dart';

class RequestAuthAction extends TelegramAction {
  RequestAuthAction(this._userManager, MessageInfo info, TaleApiWrapper taleApi,
      TelegramWrapper telegramWrapper)
      : super(info, taleApi, telegramWrapper);

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
      replyMarkup: InlineKeyboardMarkup(inline_keyboard: [
        [
          InlineKeyboardButton(
              text: "/confirm", callback_data: "/confirm ${info.sessionInfo.sessionId}")
        ]
      ]),
    );
  }
}
