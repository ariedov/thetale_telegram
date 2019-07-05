import 'dart:async';

import 'package:epictale_telegram/room/cards/receive_cards_action.dart';
import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:thetale_api/thetale_api.dart';

import 'utils.dart';

void main() {
  MessageInfo messageInfo;
  TaleApiMock taleApi;
  TelegramApiMock telegramApi;

  ReceiveCardsAction action;

  setUp(() {
    messageInfo = MessageInfo(chatId: 0, messageId: 0);
    taleApi = TaleApiMock();
    telegramApi = TelegramApiMock();

    action = ReceiveCardsAction(messageInfo, taleApi, telegramApi);
  });

  test("test build card list", () async {
    when(taleApi.receiveNewCards()).thenAnswer(
        (_) => Future(() => ReceivedCardList([
          buildCard(name: "first"), buildCard(name: "second"), buildCard(name: "third")
        ])));

    await action.performAction();

    verify(telegramApi.sendMessage(0, "Получено новых карт 3:\n🃏 first\n🃏 second\n🃏 third"));
  });

  test("test build no cards", () async {
    when(taleApi.receiveNewCards())
        .thenAnswer((_) => Future(() => ReceivedCardList([])));

    await action.performAction();

    verify(telegramApi.sendMessage(0, "Не получилось взять новые карты."));
  });

  test("test build null cards", () async {
    when(taleApi.receiveNewCards())
        .thenAnswer((_) => Future(() => ReceivedCardList(null)));

    await action.performAction();

    verify(telegramApi.sendMessage(0, "Не получилось взять новые карты."));

  });
}

class TaleApiMock extends Mock implements TaleApiWrapper {}

class TelegramApiMock extends Mock implements TelegramWrapper {}
