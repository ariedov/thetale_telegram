import 'dart:async';
import 'dart:io';

import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:epictale_telegram/server.dart';

const String appKey = "663762224:AAEatW0mX8svEAZdgGpMOdGJZYXKIasONNc";

class Application {
  Future init() async {

    final server = Server();
    final api = TelegramApi(appKey);

    final portEnv = Platform.environment['PORT'];
    final portInt = portEnv == null ? 8080 : int.parse(portEnv);
    print("port $portInt");
    await server.startServer(port: portInt);

    await api.setupWebHook("https://epictale-telegram.herokuapp.com/$appKey");

    await server.listen((method, path) {
      return {"message": "hello"};
    });
  }
}
