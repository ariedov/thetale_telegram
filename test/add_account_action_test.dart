import 'dart:async';

import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/room/add_account_action.dart';
import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:thetale_api/thetale_api.dart';

void main() {
  TelegramApiMock telegram;
  TaleApiMock taleApi;

  MessageInfo messageInfo;
  TaleApiWrapper taleApiWrapper;

  AddAccountAction action;

  setUp(() {
    taleApi = TaleApiMock();

    messageInfo = MessageInfo(chatId: 0, messageId: 0);
    taleApiWrapper = TaleApiWrapper(taleApi, "apiUrl");
    telegram = TelegramApiMock();

    action = AddAccountAction(messageInfo, taleApiWrapper, telegram);
  });

  test("test add account", () async {
    final sessionInfo = SessionInfo("sessionId", "csrfToken");
    final storage = SessionStorageMock();

    when(taleApi.apiInfo()).thenAnswer((_) => Future(() => TaleResponse(
        sessionInfo,
        ApiInfo("staticContent", "gameVersion", 1, 1, "accountName"))));
    when(taleApi.auth(
      headers: anyNamed("headers"),
      applicationName: anyNamed("applicationName"),
      applicationDescription: anyNamed("applicationDescription"),
      applicationInfo: anyNamed("applicationInfo"),
    )).thenAnswer((_) => Future(() => ThirdPartyLink("link")));

    taleApiWrapper.setStorage(storage);

    await action.performAction();

    verify(taleApi.auth(
        headers: {
          "Referer": "apiUrl",
          "X-CSRFToken": "csrfToken",
          "Cookie":
              "csrftoken=csrfToken; sessionid=sessionId"
        },
        applicationName: applicationName,
        applicationInfo: applicationInfo,
        applicationDescription: applicationDescription));
    expect(await storage.readSession(), sessionInfo);
  });
}

class TaleApiMock extends Mock implements TaleApi {}

class TelegramApiMock extends Mock implements TelegramWrapper {}

class SessionStorageMock implements SessionStorage {
  SessionInfo _sessionInfo;

  @override
  Future<void> addSession(SessionInfo sessionInfo) {
    _sessionInfo = sessionInfo;
    return null;
  }

  @override
  Future<SessionInfo> readSession() async {
    return _sessionInfo;
  }

  @override
  Future<void> updateSession(SessionInfo sessionInfo) {
    _sessionInfo = sessionInfo;
    return null;
  }
}
