import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room.dart';
import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/room/action_router.dart';
import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:teledart/model.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:thetale_api/thetale_api.dart';

void main() {
  UserManagerMock userManager;
  MessageInfo messageInfo;
  TaleApiMock taleMock;
  ActionRouterMock routerMock;
  TelegramWrapper telegram;
  Room room;

  setUp(() {
    messageInfo = MessageInfo(chatId: 0, messageId: 0);
    userManager = UserManagerMock();
    taleMock = TaleApiMock();
    routerMock = ActionRouterMock();
    telegram = TelegramMock();

    room = Room(userManager, taleMock, routerMock);
  });

  test("test single user action", () async {
    final update = createMessageWithAction("/start");
    final action = SingleUserTelegramAction();
    when(routerMock.route(messageInfo, telegram, "/start")).thenReturn(action);

    await room.processMessage(messageInfo, telegram, update);

    verify(action.apply(account: null));
  });

  test('test message processing', () {
    const message = "/help 123";
    final actionAccount = getActionAccountFromMessage(message);

    expect(actionAccount.action, "/help");
    expect(actionAccount.account, "123");
  });

  test('test message without account', () {
    const message = "/help";
    final actionAccount = getActionAccountFromMessage(message);

    expect(actionAccount.action, "/help");
    expect(actionAccount.account, null);
  });

  test('test process multi user action without accounts at all', () async {
    final update = createMessageWithAction("/help");
    final action = MultiUserTelegramAction();

    when(routerMock.route(messageInfo, telegram, "/help")).thenReturn(action);

    await room.processMessage(messageInfo, telegram, update);

    verify(action.performEmptyAction());
  });

  test('test process multi user action without account with single available',
      () async {
    final action = MultiUserTelegramAction();
    final update = createMessageWithAction("/help");

    when(userManager.readUserSession())
        .thenAnswer((_) => Future(() => [SessionInfo("session", "info")]));
    when(routerMock.route(messageInfo, telegram, "/help")).thenReturn(action);

    await room.processMessage(messageInfo, telegram, update);

    verify(action.apply(account: "session"));
  });

  test('test process multi user action without account with multiple available',
      () async {
    final update = createMessageWithAction("/help");
    final action = MultiUserTelegramAction();

    when(userManager.readUserSession()).thenAnswer((_) => Future(
        () => [SessionInfo("session", "info"), SessionInfo("second", "info")]));
    when(taleMock.gameInfo()).thenAnswer(
        (_) => Future(() => createGameInfoWithCharacterName("character")));
    when(routerMock.route(messageInfo, telegram, "/help")).thenReturn(action);

    await room.processMessage(messageInfo, telegram, update);

    verify(action.performChooserAction(any));
    verify(taleMock.setStorage(any));
  });

  test(
      'test process multi user action with first account with multiple available',
      () async {
    final update = createMessageWithAction("/help session");
    final action = MultiUserTelegramAction();

    when(userManager.readUserSession()).thenAnswer((_) => Future(
        () => [SessionInfo("session", "info"), SessionInfo("second", "info")]));
    when(taleMock.gameInfo()).thenAnswer(
        (_) => Future(() => createGameInfoWithCharacterName("character")));
    when(routerMock.route(messageInfo, telegram, "/help")).thenReturn(action);

    await room.processMessage(messageInfo, telegram, update);

    verify(action.apply(account: "session"));
  });

  test(
      'test process multi user action with second account with multiple available',
      () async {
    final update = createMessageWithAction("/help second");
    final action = MultiUserTelegramAction();

    when(userManager.readUserSession()).thenAnswer((_) => Future(
        () => [SessionInfo("session", "info"), SessionInfo("second", "info")]));
    when(taleMock.gameInfo()).thenAnswer(
        (_) => Future(() => createGameInfoWithCharacterName("character")));
    when(routerMock.route(messageInfo, telegram, "/help")).thenReturn(action);

    await room.processMessage(messageInfo, telegram, update);

    verify(action.apply(account: "second"));
  });

  test('test process multi user action with account', () async {
    final message = createMessageWithAction("/help session");
    final action = MultiUserTelegramAction();

    when(userManager.readUserSession())
        .thenAnswer((_) => Future(() => [SessionInfo("session", "info")]));
    when(taleMock.gameInfo()).thenAnswer(
        (_) => Future(() => createGameInfoWithCharacterName("character")));
    when(routerMock.route(messageInfo, telegram, "/help")).thenReturn(action);

    await room.processMessage(messageInfo, telegram, message);

    verify(action.apply(account: "session"));
  });

  test('test process multi user action with empty session', () async {
    final message = createMessageWithAction("/help session");
    final action = MultiUserTelegramAction();

    when(routerMock.route(messageInfo, telegram, "/help")).thenReturn(action);

    await room.processMessage(messageInfo, telegram, message);

    verify(action.performEmptyAction());
  });

  test('test process first user action with multiple sessions', () async {
    final message = createMessageWithAction("/confirm session");
    final action = SingleUserTelegramAction();

    when(userManager.readUserSession()).thenAnswer((_) => Future(
        () => [SessionInfo("session", "info"), SessionInfo("second", "info")]));
    when(routerMock.route(messageInfo, telegram, "/confirm")).thenReturn(action);

    await room.processMessage(messageInfo, telegram, message);

    verify(action.apply(account: "session"));
  });

  test('test process second user action with multiple sessions', () async {
    final update = createMessageWithAction("/confirm second");
    final action = SingleUserTelegramAction();

    when(userManager.readUserSession()).thenAnswer((_) => Future(
        () => [SessionInfo("session", "info"), SessionInfo("second", "info")]));
    when(routerMock.route(messageInfo, telegram, "/confirm")).thenReturn(action);

    await room.processMessage(messageInfo, telegram, update);

    verify(action.apply(account: "second"));
  });

  test('test process second user action with multiple sessions', () async {
    final update = createMessageWithAction("/confirm session");
    final action = SingleUserTelegramAction();

    when(routerMock.route(messageInfo, telegram, "/confirm")).thenReturn(action);

    await room.processMessage(messageInfo, telegram, update);

    verify(action.apply(account: null));
  });
}

Message createMessageWithAction(String action) {
  return Message(
      message_id: 0,
      from: User(id: 0, first_name: "firstName", last_name: "lastName", username: "username", language_code: "languageCode",
          is_bot: false),
      chat: Chat(id: 0, first_name: "firstName", last_name: "lastName", username: "userName", type: "private"),
      text: action);
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

class TelegramMock extends Mock implements TelegramWrapper {}
