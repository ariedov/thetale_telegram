import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room/action_router.dart';
import 'package:epictale_telegram/room/add_account_action.dart';
import 'package:epictale_telegram/room/cards/new_cards_action.dart';
import 'package:epictale_telegram/room/cards/receive_cards_action.dart';
import 'package:epictale_telegram/room/confirm_auth_action.dart';
import 'package:epictale_telegram/room/help_action.dart';
import 'package:epictale_telegram/room/info_action.dart';
import 'package:epictale_telegram/room/remove_account_action.dart';
import 'package:epictale_telegram/room/request_auth_action.dart';
import 'package:epictale_telegram/room/start_action.dart';
import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:thetale_api/thetale_api.dart';

void main() {
  TelegramWrapper telegram;
  ChatInfo chatInfo;
  ActionRouter router;

  setUp(() {
    final userManager = UserManagerMock();
    final taleApi = TaleApiMock();

    router = ActionRouter(userManager, taleApi);
    telegram = TelegramApiMock();
    chatInfo = ChatInfo(0);
  });

  test("test start action", () {
    final action = router.route(chatInfo, telegram, "/start");

    expect(action, const TypeMatcher<StartAction>());
  });

  test("test confirm action", () {
    final action = router.route(chatInfo, telegram, "/confirm");

    expect(action, const TypeMatcher<ConfirmAuthAction>());
  });

  test("test auth action", () {
    final action = router.route(chatInfo, telegram, "/auth");

    expect(action, const TypeMatcher<RequestAuthAction>());
  });

  test("test add action", () {
    final action = router.route(chatInfo, telegram, "/add");

    expect(action, const TypeMatcher<AddAccountAction>());
  });

  test("test remove action", () {
    final action = router.route(chatInfo, telegram, "/remove");

    expect(action, const TypeMatcher<RemoveAccountAction>());
  });

  test("test info action", () {
    final action = router.route(chatInfo, telegram, "/info");

    expect(action, const TypeMatcher<InfoAction>());
  });

  test("test help action", () {
    final action = router.route(chatInfo, telegram, "/help");

    expect(action, const TypeMatcher<HelpAction>());
  });

  test("test new cards action", () {
    final action = router.route(chatInfo, telegram, "/cards");

    expect(action, const TypeMatcher<CardsAction>());
  });

  test("test receive cards action", () {
    final action = router.route(chatInfo, telegram, "/cardsreceive");

    expect(action, const TypeMatcher<ReceiveCardsAction>());
  });

  test("test wrong action", () {
    expect(() => router.route(chatInfo, telegram, "wrong"), throwsException);
  });
}

class UserManagerMock extends Mock implements UserManager {}

class TaleApiMock extends Mock implements TaleApiWrapper {}

class TelegramApiMock extends Mock implements TelegramWrapper {}
