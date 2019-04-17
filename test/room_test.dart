import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:thetale_api/thetale_api.dart';

void main() {
  test("test start", () async {
    final userManager = UserManagerMock();
    final taleMock = TaleApiMock();
    final telegramMock = TelegramApiMock();
    final room = Room(userManager, taleMock, telegramMock);

    final update = Update(
        0,
        null,
        Message(
            0,
            User(0, "firstName", "lastName", "username", "languageCode",
                isBot: false),
            Chat(0, "firstName", "lastName", "userName", ChatType.private),
            0,
            "/start",
            []));

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
}

class UserManagerMock extends Mock implements UserManager {}

class TaleApiMock extends Mock implements TaleApiWrapper {}

class TelegramApiMock extends Mock implements TelegramApi {}
