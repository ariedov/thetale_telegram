import 'dart:async';
import 'dart:io';

import 'package:epictale_telegram/api/telegram_api.dart';
import 'package:epictale_telegram/server.dart';

const String appKey = "663762224:AAEatW0mX8svEAZdgGpMOdGJZYXKIasONNc";

class Application {
  Future init() async {

    final server = Server();
    final api = TelegramApi(appKey);

    final port = Platform.environment['PORT'];
    print("Environment: ${Platform.environment}");
    print("port: $port");
    await server.startServer(port: port == null ? 8080 : int.parse(port));

    await api.setupWebHook("https://epictale-telegram.herokuapp.com/$appKey");

    await server.listen((method, path) {
      return {"message": "hello"};
    });
  }
}
