import 'dart:async';

import 'package:epictale_telegram/room/confirm_auth_action.dart';
import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:mockito/mockito.dart';
import 'package:teledart/model.dart';
import 'package:test/test.dart';
import 'package:thetale_api/thetale_api.dart';

import 'utils.dart';

void main() {

  MessageInfo messageInfo;
  TaleApiWrapper taleApi;
  TelegramWrapper telegramWrapper;
  ConfirmAuthAction action;

  setUp(() {
    messageInfo = MessageInfo(chatId: 0, messageId: 0);
    taleApi = TaleApiMock();
    telegramWrapper = TelegramApiMock();
    action = ConfirmAuthAction(messageInfo, taleApi, telegramWrapper);
  });

  test("test confirmation successful", () async {
    when(taleApi.authStatus()).thenAnswer((_) => Future(() => TaleResponse(null, createSuccessfulStatus())));
    when(taleApi.gameInfo()).thenAnswer((_) => Future(() => createGameInfoWithCharacterName("name")));

    await action.performAction();

    verify(telegramWrapper.updateMessageReplyMarkup(messageInfo, any));
    verify(telegramWrapper.updateMessageText(messageInfo, "Авторизация прошла успешно!"));
  });

  test("test confirmation unsuccsessful", () async {
    when(taleApi.authStatus()).thenAnswer((_) => Future(() => TaleResponse(null, createUnsuccessfulStatus())));
    when(taleApi.gameInfo()).thenAnswer((_) => Future(() => createGameInfoWithCharacterName("name")));

    await action.performAction();

    verify(telegramWrapper.sendMessage(0, "Тебе стоит попытаться еще раз."));
  });
}

ThirdPartyStatus createSuccessfulStatus() => ThirdPartyStatus(
  "url", 1, "accountName", 1000000, 2
);

ThirdPartyStatus createUnsuccessfulStatus() => ThirdPartyStatus(
  "url", 1, "accountName", 1000000, 1
);

class TaleApiMock extends Mock implements TaleApiWrapper {}

class TelegramApiMock extends Mock implements TelegramWrapper {}