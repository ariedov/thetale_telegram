import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/tale_api/tale_api.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';

class RoomFactory {

  Room createRoom(int chatId) {
    final userManager = MemoryUserManager(chatId);
    final taleApi = TaleApi(userManager);
    final telegramApi = TelegramApi(chatId);

    return Room(chatId, taleApi, telegramApi);
  }
}

class RoomManager {

  final Map<int, Room> _rooms = {};
  final RoomFactory _roomFactory;

  RoomManager(this._roomFactory);

  Room getRoom(int chatId) {
    if (_rooms[chatId] != null) {
      return _rooms[chatId];
    }
    return _rooms[chatId] = _roomFactory.createRoom(chatId);
  }
}

class Room {

  final int _chatId;
  final TaleApi _taleApi;
  final TelegramApi _telegramApi;

  Room(this._chatId, this._taleApi, this._telegramApi);

  /// This method will call both telegram and tale api
  void processUpdate(Update update) {
    _telegramApi.sendMessage("I have received your message!");
  }
}