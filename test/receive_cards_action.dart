import 'dart:async';

import 'package:epictale_telegram/room/cards/receive_cards_action.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:thetale_api/thetale_api.dart';

import 'utils.dart';

void main() {
  TaleApiMock taleApi;
  TelegramApiMock telegramApi;

  ReceiveCardsAction action;

  setUp(() {
    taleApi = TaleApiMock();
    telegramApi = TelegramApiMock();

    action = ReceiveCardsAction(taleApi, telegramApi);
  });

  test("test build card list", () async {
    when(taleApi.receiveNewCards()).thenAnswer(
        (_) => Future(() => ReceivedCardList([
          buildCard(name: "first"), buildCard(name: "second"), buildCard(name: "third")
        ])));

    await action.performAction();

    verify(telegramApi.sendMessage("Получено новых карт 3:\n🃏 first\n🃏 second\n🃏 third"));
  });

  test("test build no cards", () async {
    when(taleApi.receiveNewCards())
        .thenAnswer((_) => Future(() => ReceivedCardList([])));

    await action.performAction();

    verify(telegramApi.sendMessage("Не получилось взять новые карты."));
  });

  test("test build null cards", () async {
    when(taleApi.receiveNewCards())
        .thenAnswer((_) => Future(() => ReceivedCardList(null)));

    await action.performAction();

    verify(telegramApi.sendMessage("Не получилось взять новые карты."));

  });
}

class TaleApiMock extends Mock implements TaleApiWrapper {}

class TelegramApiMock extends Mock implements TelegramApi {}
