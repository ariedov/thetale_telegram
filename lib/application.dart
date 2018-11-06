import 'dart:async';
import 'dart:convert';

import 'package:epictale_telegram/constants.dart';
import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room.dart';
import 'package:epictale_telegram/telegram_api/converters.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:epictale_telegram/server.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Application {
  Future init() async {
    final server = Server();

    print("port $port"); 
    await server.startServer(port: port);

    await setupWebHook(telegramWebhook);

    final db = Db(mongodbUri);
    await db.open();

    try {
      final userProvider = UserManagerProvider(db);
      final roomFactory = RoomFactory(userProvider);
      final roomManager = RoomManager(roomFactory);

      await for (String data in server.listen()) {
        print(data);
        final update = convertUpdate(json.decode(data));
        final room = roomManager.getRoom(update.chatId);

        processRoom(room, update);
      }
    } catch (e) {
      print(e);
    } finally {
      await db.close();
    }
  }

  void processRoom(Room room, Update update) async {
    await room.processUpdate(update);
  }
}
