import 'dart:async';

import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:teledart/model.dart';

import 'package:thetale_api/thetale_api.dart';

class CardsAction extends MultiUserAction {
  CardsAction(
      ChatInfo chatInfo, TaleApiWrapper taleApi, TelegramWrapper telegram)
      : super(chatInfo, taleApi, telegram);

  static const String name = "/cards";

  @override
  Future<void> performAction({String account}) async {
    final cards = await taleApi.getCards();

    if (cards.newCards > 0) {
      await trySendMessage("Количество доступных карт: *${cards.newCards}*",
          replyMarkup: InlineKeyboardMarkup(inline_keyboard: [
            [
              InlineKeyboardButton(
                  text: "Получить!", callback_data: "/cardsreceive ${account}")
            ]
          ]));
    } else {
      await trySendMessage("Новых карт нет.");
    }
  }

  @override
  Future<void> performChooserAction(Map<String, String> sessionNameMap) async {
    if (sessionNameMap.isNotEmpty) {
      await trySendMessage(
          "Выбери для какого персонажа ты хочешь узнать количество новых карт.",
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
        "Чтобы узнать количество новых карт нужно войти в аккаунт. Попробуй /auth или /start.");
  }
}
