import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/room/add_account_action.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:thetale_api/thetale_api.dart';

void main() {
  TelegramApiMock telegramApi;
  TaleApiMock taleApi;

  TaleApiWrapper taleApiWrapper;

  AddAccountAction action;

  setUp(() {
    taleApi = TaleApiMock();

    taleApiWrapper = TaleApiWrapper(taleApi, "");
    telegramApi = TelegramApiMock();

    action = AddAccountAction(taleApiWrapper, telegramApi);
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
        headers: anyNamed("headers"),
        applicationName: applicationName,
        applicationInfo: applicationInfo,
        applicationDescription: applicationDescription));
    expect(await storage.readSession(), sessionInfo);
  });

}

class TaleApiMock extends Mock implements TaleApi {}

class TelegramApiMock extends Mock implements TelegramApi {}

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
