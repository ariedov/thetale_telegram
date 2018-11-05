import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

    final portEnv = Platform.environment['PORT'];
    final portInt = portEnv == null ? 8080 : int.parse(portEnv);
    print("port $portInt"); 
    await server.startServer(port: portInt);

    await setupWebHook("https://epictale-telegram.herokuapp.com/");

    final db = Db(Platform.environment['MONGODB_URI']);
    await db.open();

    try {
      final userProvider = UserManagerProvider(db);
      final roomFactory = RoomFactory(userProvider);
      final roomManager = RoomManager(roomFactory);

      await for (String data in server.listen()) {
        print(data);
        final update = convertUpdate(json.decode(data));
        final room = roomManager.getRoom(update.message.chat.id);

        processRoom(room, update);
      }
    } finally {
      await db.close();
    }
  }

  void processRoom(Room room, Update update) async {
    await room.processUpdate(update);
  }
}
