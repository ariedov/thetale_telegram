import 'dart:async';

import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:teledart/model.dart';
import 'package:thetale_api/thetale_api.dart';

class AddAccountAction extends TelegramAction {
  AddAccountAction(
      MessageInfo messageInfo, TaleApiWrapper taleApi, TelegramWrapper telegram)
      : super(messageInfo, taleApi, telegram);

  static const String name = "/add";

  @override
  Future<void> performAction({String account}) async {
    final info = await taleApi.apiInfo();

    final link = await taleApi.auth(
        applicationName, applicationInfo, applicationDescription);
    await trySendMessage(
      "Чтобы добавить аккаунт - перейди по ссылке ${apiUrl}${link.authorizationPage}",
      replyMarkup: InlineKeyboardMarkup(inline_keyboard: [
        [
          InlineKeyboardButton(
              text: "/confirm",
              callback_data: "/confirm ${info.sessionInfo.sessionId}")
        ]
      ]),
    );
  }
}
