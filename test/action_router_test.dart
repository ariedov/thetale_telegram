import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room/action_router.dart';
import 'package:epictale_telegram/room/add_account_action.dart';
import 'package:epictale_telegram/room/confirm_auth_action.dart';
import 'package:epictale_telegram/room/help_action.dart';
import 'package:epictale_telegram/room/info_action.dart';
import 'package:epictale_telegram/room/remove_account_action.dart';
import 'package:epictale_telegram/room/request_auth_action.dart';
import 'package:epictale_telegram/room/start_action.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:thetale_api/thetale_api.dart';

void main() {
  ActionRouter router;

  setUp(() {
    final userManager = UserManagerMock();
    final taleApi = TaleApiMock();
    final telegramApi = TelegramApiMock();

    router = ActionRouter(userManager, taleApi, telegramApi);
  });

  test("test start action", () {
    final action = router.route("/start");

    expect(action, const TypeMatcher<StartAction>());
  });

  test("test confirm action", () {
    final action = router.route("/confirm");

    expect(action, const TypeMatcher<ConfirmAuthAction>());
  });

  test("test auth action", () {
    final action = router.route("/auth");

    expect(action, const TypeMatcher<RequestAuthAction>());
  });

  test("test add action", () {
    final action = router.route("/add");

    expect(action, const TypeMatcher<AddAccountAction>());
  });

  test("test remove action", () {
    final action = router.route("/remove");

    expect(action, const TypeMatcher<RemoveAccountAction>());
  });

  test("test info action", () {
    final action = router.route("/info");

    expect(action, const TypeMatcher<InfoAction>());
  });

  test("test help action", () {
    final action = router.route("/help");

    expect(action, const TypeMatcher<HelpAction>());
  });

  test("test wrong action", () {
    expect(() => router.route("wrong"), throwsException);
  });
}

class UserManagerMock extends Mock implements UserManager {}

class TaleApiMock extends Mock implements TaleApiWrapper {}

class TelegramApiMock extends Mock implements TelegramApi {}
