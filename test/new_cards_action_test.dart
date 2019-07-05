import 'dart:async';

import 'package:epictale_telegram/room/cards/new_cards_action.dart';
import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:thetale_api/thetale_api.dart';

void main() {
  MessageInfo messageInfo;
  TaleApiMock taleApi;
  TelegramApiMock telegramApi;

  CardsAction action;

  setUp(() {
    messageInfo = MessageInfo(chatId: 0, messageId: 1);
    taleApi = TaleApiMock();
    telegramApi = TelegramApiMock();

    action = CardsAction(messageInfo, taleApi, telegramApi);
  });

  test("test no new cards", () async {
    when(taleApi.getCards()).thenAnswer((_) => Future(() => CardList(0, [])));

    await action.performAction();

    verify(telegramApi.sendMessage(0, "Новых карт нет.", replyMarkup: null));
  });

  test("test available new cards", () async {
    when(taleApi.getCards()).thenAnswer((_) => Future(() => CardList(1, [])));

    await action.performAction();

    verify(telegramApi.sendMessage(0, "Количество доступных карт: *1*", replyMarkup: anyNamed("replyMarkup")));
    verifyNever(telegramApi.sendMessage(0, "Новых карт нет.", replyMarkup: null));
  });
}

class TaleApiMock extends Mock implements TaleApiWrapper {}

class TelegramApiMock extends Mock implements TelegramWrapper {}