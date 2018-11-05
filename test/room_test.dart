import 'package:epictale_telegram/room.dart';
import 'package:epictale_telegram/tale_api/tale_api.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

void main() {
  test("test start", () async {
    final taleMock = TaleApiMock();
    final telegramMock = TelegramApiMock();
    final room = Room(taleMock, telegramMock);

    final update = Update(
      0,
      Message(0, 
      User(0, "firstName", "lastName", "username", "languageCode", isBot: false), 
      Chat(0, "firstName", "lastName", "userName", ChatType.private), 
      0, 
      "/start", 
      [])
    );

    await room.processUpdate(update);

    verify(taleMock.apiInfo());
    verify(telegramMock.sendMessage(any));
  });
}

class TaleApiMock extends Mock implements TaleApi {}

class TelegramApiMock extends Mock implements TelegramApi {}