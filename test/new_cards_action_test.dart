import 'dart:async';

import 'package:epictale_telegram/room/cards/new_cards_action.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:thetale_api/thetale_api.dart';

void main() {
  TaleApiMock taleApi;
  TelegramApiMock telegramApi;

  NewCardsAction action;

  setUp(() {
    taleApi = TaleApiMock();
    telegramApi = TelegramApiMock();

    action = NewCardsAction(taleApi, telegramApi);
  });

  test("test no new cards", () async {
    when(taleApi.getCards()).thenAnswer((_) => Future(() => CardList(0, [])));

    await action.performAction();

    verify(telegramApi.sendMessage(any, inlineKeyboard: null));
  });

  test("test available new cards", () async {
    when(taleApi.getCards()).thenAnswer((_) => Future(() => CardList(1, [])));

    await action.performAction();

    verify(telegramApi.sendMessage(any, inlineKeyboard: anyNamed("inlineKeyboard")));
    verifyNever(telegramApi.sendMessage(any, inlineKeyboard: null));
  });
}

class TaleApiMock extends Mock implements TaleApiWrapper {}

class TelegramApiMock extends Mock implements TelegramApi {}