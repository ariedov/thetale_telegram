import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:thetale_api/thetale_api.dart';

void main() {
  UserSessionStorage sessionStorage;

  setUp(() {
    sessionStorage =
        UserSessionStorage(UserManagerMock(), SessionInfo("sessionid", "csrf"));
  });

  test("add session test", () async {
    final newInfo = SessionInfo("added", "session");
    await sessionStorage.addSession(newInfo);

    final info = await sessionStorage.readSession();
    expect(info, newInfo);
  });

  test("update session csrf test", () async {
    final newInfo = SessionInfo(null, "newcsrf");
    await sessionStorage.updateSession(newInfo);

    final info = await sessionStorage.readSession();
    expect(info.sessionId, "sessionid");
    expect(info.csrfToken, "newcsrf");
  });

  test("update session id test", () async {
    final newInfo = SessionInfo("newsessionid", null);
    await sessionStorage.updateSession(newInfo);

    final info = await sessionStorage.readSession();
    expect(info.sessionId, "newsessionid");
    expect(info.csrfToken, "csrf");
  });
}

class UserManagerMock extends Mock implements UserManager {}
