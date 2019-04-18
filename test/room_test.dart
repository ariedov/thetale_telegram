import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room.dart';
import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/room/action_router.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:thetale_api/thetale_api.dart';

void main() {
  UserManagerMock userManager;
  TaleApiMock taleMock;
  ActionRouterMock routerMock;
  Room room;

  setUp(() {
    userManager = UserManagerMock();
    taleMock = TaleApiMock();
    routerMock = ActionRouterMock();

    room = Room(userManager, taleMock, routerMock);
  });

  test("test single user action", () async {
    final update = createUpdateWithAction("/start");
    final action = SingleUserTelegramAction();
    when(routerMock.route("/start")).thenReturn(action);

    await room.processUpdate(update);

    verify(action.apply(account: null));
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
    final action = MultiUserTelegramAction();

    when(routerMock.route("/help")).thenReturn(action);

    await room.processUpdate(update);

    verify(action.performEmptyAction());
  });

  test('test process multi user action without account with single available',
      () async {
    final action = MultiUserTelegramAction();
    final update = createUpdateWithAction("/help");

    when(userManager.readUserSession())
        .thenAnswer((_) => Future(() => [SessionInfo("session", "info")]));
    when(routerMock.route("/help")).thenReturn(action);

    await room.processUpdate(update);

    verify(action.apply(account: "session"));
  });

  test('test process multi user action without account with multiple available',
      () async {
    final update = createUpdateWithAction("/help");
    final action = MultiUserTelegramAction();

    when(userManager.readUserSession()).thenAnswer((_) => Future(
        () => [SessionInfo("session", "info"), SessionInfo("second", "info")]));
    when(taleMock.gameInfo()).thenAnswer(
        (_) => Future(() => createGameInfoWithCharacterName("character")));
    when(routerMock.route("/help")).thenReturn(action);

    await room.processUpdate(update);

    verify(action.performChooserAction(any));
  });

  test('test process multi user action with account', () async {
    final update = createUpdateWithAction("/help session");
    final action = MultiUserTelegramAction();

    when(userManager.readUserSession())
        .thenAnswer((_) => Future(() => [SessionInfo("session", "info")]));
    when(taleMock.gameInfo()).thenAnswer(
        (_) => Future(() => createGameInfoWithCharacterName("character")));
    when(routerMock.route("/help")).thenReturn(action);

    await room.processUpdate(update);

    verify(action.apply(account: "session"));
  });

  test('test process multi user action with empty session', () async {
    final update = createUpdateWithAction("/help session");
    final action = MultiUserTelegramAction();

    when(routerMock.route("/help")).thenReturn(action);

    await room.processUpdate(update);

    verify(action.performEmptyAction());
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

class SingleUserTelegramAction extends Mock implements TelegramAction {}

class MultiUserTelegramAction extends Mock implements MultiUserAction {}

class UserManagerMock extends Mock implements UserManager {}

class TaleApiMock extends Mock implements TaleApiWrapper {}

class ActionRouterMock extends Mock implements ActionRouter {}
