import 'dart:async';

import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:thetale_api/thetale_api.dart';

class NewCardsAction extends MultiUserAction {
  NewCardsAction(TaleApiWrapper taleApi, TelegramApi telegramApi) : super(taleApi, telegramApi);

  static const String name = "/cardscount";

  @override
  Future<void> performAction({String account}) async {
    final cards = await taleApi.getCards();
    
    if (cards.newCards > 0) {
        await trySendMessage(
            "Количество доступных карт: *${cards.newCards}*", 
              inlineKeyboard: InlineKeyboard([[
                InlineKeyboardButton("Получить!", "/cardsclaim")
              ]]));
    } else {
        await trySendMessage("Новых карт нет.");
    }
  }

  @override
  Future<void> performChooserAction(Map<String, String> sessionNameMap) async {
    if (sessionNameMap.isNotEmpty) {
      await trySendMessage("Выбери для какого персонажа ты хочешь узнать количество новых карт.",
          inlineKeyboard:
              InlineKeyboard(buildAccountListAction(sessionNameMap, name)));
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