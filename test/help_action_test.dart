import 'package:epictale_telegram/room/help_action.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:thetale_api/thetale_api.dart';

void main() {

  TaleApiMock taleApi;
  TelegramApiMock telegramApi;
  HelpAction action;

  setUp(() {
    taleApi = TaleApiMock();
    telegramApi = TelegramApiMock();
    action = HelpAction(taleApi, telegramApi);
  });

  test('test empty action', () async {
    await action.performEmptyAction();

    verify(telegramApi.sendMessage("Чтобы помочь нужно войти в аккаунт. Попробуй /auth или /start."));
  });
}

class TaleApiMock extends Mock implements TaleApiWrapper {}

class TelegramApiMock extends Mock implements TelegramApi {}
