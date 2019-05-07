import 'dart:async';

import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:thetale_api/thetale_api.dart';

class ReceiveCardsAction extends MultiUserAction {
  ReceiveCardsAction(TaleApiWrapper taleApi, TelegramApi telegramApi) : super(taleApi, telegramApi);

  static const String name = "/cardsreceive";

  @override
  Future<void> performAction({String account}) async {
    final result = await taleApi.receiveNewCards();

    // TODO: udpate new cards message if available

    if (result?.cards?.isNotEmpty ?? false) {
      await trySendMessage(buildCardList(result.cards));
    } else {
      await trySendMessage("Не получилось взять новые карты.");
    }
  }

  @override
  Future<void> performChooserAction(Map<String, String> sessionNameMap) async {
        if (sessionNameMap.isNotEmpty) {
      await trySendMessage("Выбери для какого персонажа ты хочешь взять новые карты.",
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
          "Чтобы забрать новые карты нужно войти в аккаунт. Попробуй /auth или /start.");
  }

  String buildCardList(List<Card> cards) {
    return cards.fold(StringBuffer(), (buffer, card) { 
      buffer.write("🃏 ${card.name}");
      buffer.writeln();
      return buffer;
    }).toString().trim();
  }
}