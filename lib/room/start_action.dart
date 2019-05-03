import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:thetale_api/thetale_api.dart';

class StartAction extends TelegramAction {
  StartAction(
      this._userManager, TaleApiWrapper taleApi, TelegramApi telegramApi)
      : super(taleApi, telegramApi);

  static const String name = "/start";

  final UserManager _userManager;

  @override
  Future<void> performAction({String account}) async {
    await trySendMessage("Привет, хранитель!");

    await _userManager.clearAll();
    final info = await taleApi.apiInfo();

    await trySendMessage("""
        Версия игры ${info.data.gameVersion}. Сейчас попробую тебя авторизовать.
        /start - начать все по новой
        /auth - снова авторизироваться
        /confirm - подтвердить авторизацию после того как дал доступ боту (мне)

        /add - добавить персонажа
        /remove - удалить персонажа

        /help - помочь своему герою
        /info - получить информацию о герое

        /cardscount - узнать есть ли новые карты
        """);

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
