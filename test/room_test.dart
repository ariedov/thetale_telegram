import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:thetale_api/thetale_api.dart';

void main() {
  UserManagerMock userManager;
  TaleApiMock taleMock;
  TelegramApiMock telegramMock;
  Room room;

  setUp(() {
    userManager = UserManagerMock();
    taleMock = TaleApiMock();
    telegramMock = TelegramApiMock();

    room = Room(userManager, taleMock, telegramMock);
  });
  test("test start", () async {
    final update = createUpdateWithAction("/start");

    await room.processUpdate(update);

    verify(taleMock.apiInfo());
    verify(telegramMock.sendMessage(any));
  });

  test('test message processing', () {
    const message = "/help 123";
    final actionAccount = processMessage(message);

    expect(actionAccount.action, "/help");
    expect(actionAccount.account, "123");
  });

  test('test message without account', () {
    const message = "/help";
    final actionAccount = processMessage(message);

    expect(actionAccount.action, "/help");
    expect(actionAccount.account, null);
  });

  test('test process multi user action without accounts at all', () async {
    final update = createUpdateWithAction("/help");

    await room.processUpdate(update);

    verify(telegramMock.sendMessage(any,
        inlineKeyboard: anyNamed("inlineKeyboard")));
    verifyNever(telegramMock.sendMessage(any));
  });

  test('test process multi user action without account with single available',
      () async {
    when(userManager.readUserSession())
        .thenAnswer((_) => Future(() => [SessionInfo("session", "info")]));

    final update = createUpdateWithAction("/help");
    await room.processUpdate(update);

    verify(telegramMock.sendMessage("Пытаюсь помочь!"));
  });

  test('test process multi user action without account with multiple available',
      () async {
    when(userManager.readUserSession()).thenAnswer((_) => Future(
        () => [SessionInfo("session", "info"), SessionInfo("second", "info")]));
    when(taleMock.gameInfo()).thenAnswer(
        (_) => Future(() => createGameInfoWithCharacterName("character")));

    final update = createUpdateWithAction("/help");
    await room.processUpdate(update);

    verify(telegramMock.sendMessage("Выбери кому ты хочешь помочь.",
        inlineKeyboard: anyNamed("inlineKeyboard")));
  });

  test('test process multi user action with account', () async {
    when(userManager.readUserSession())
        .thenAnswer((_) => Future(() => [SessionInfo("session", "info")]));

    when(taleMock.gameInfo()).thenAnswer(
        (_) => Future(() => createGameInfoWithCharacterName("character")));

    final update = createUpdateWithAction("/help session");
    await room.processUpdate(update);

    verify(telegramMock.sendMessage("Пытаюсь помочь!"));
  });

  test('test process multi user action with empty session', () async {
    final update = createUpdateWithAction("/help session");
    await room.processUpdate(update);

    verify(telegramMock.sendMessage("Чтобы помочь нужно войти в аккаунт. Попробуй /auth или /start."));
  });
}

Update createUpdateWithAction(String action) {
  return Update(
      0,
      null,
      Message(
          0,
          User(0, "firstName", "lastName", "username", "languageCode",
              isBot: false),
          Chat(0, "firstName", "lastName", "userName", ChatType.private),
          0,
          action,
          []));
}

GameInfo createGameInfoWithCharacterName(String character) {
//  info.account?.hero?.base?.name
  return GameInfo(
      "",
      null,
      null,
      null,
      Account(
          null,
          null,
          null,
          true,
          false,
          Hero(
              null,
              null,
              Base(null, null, null, character, null, null, null, null, null,
                  null, true),
              null,
              null,
              null,
              null),
          false,
          100),
      null);
}

class UserManagerMock extends Mock implements UserManager {}

class TaleApiMock extends Mock implements TaleApiWrapper {}

class TelegramApiMock extends Mock implements TelegramApi {}
