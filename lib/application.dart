import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:epictale_telegram/room.dart';
import 'package:epictale_telegram/telegram_api/converters.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:epictale_telegram/server.dart';

class Application {
  Future init() async {
    final server = Server();

    final portEnv = Platform.environment['PORT'];
    final portInt = portEnv == null ? 8080 : int.parse(portEnv);
    print("port $portInt");
    await server.startServer(port: portInt);

    await setupWebHook("https://epictale-telegram.herokuapp.com/");

    final roomFactory = RoomFactory();
    final roomManager = RoomManager(roomFactory);

    await for (String data in server.listen()) {
      print(data);
      final update = convertUpdate(json.decode(data));
      final room = roomManager.getRoom(update.message.chat.id);

      processRoom(room, update);
    }
  }

  void processRoom(Room room, Update update) async {
    await room.processUpdate(update);
  }
}
