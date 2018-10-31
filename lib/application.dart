import 'dart:async';

import 'package:epictale_telegram/api/telegram_api.dart';
import 'package:epictale_telegram/server.dart';

const String appKey = "663762224:AAEatW0mX8svEAZdgGpMOdGJZYXKIasONNc";

class Application {

  Future init() async {
    final server = Server();
    final api = TelegramApi(appKey);

    await server.startServer();

    await api.setupWebHook("https://epictale-telegram.herokuapp.com/$appKey");

    await server.listen((method, path) {
      return {"message": "hello"};
    });
  }
}
