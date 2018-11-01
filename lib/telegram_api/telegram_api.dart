import 'dart:async';
import 'package:http/http.dart' as http;

class TelegramApi {
  final String token;

  TelegramApi(this.token);

  Future<void> setupWebHook(String url) async {
    return http.post("https://api.telegram.org/bot$token/setWebhook",
        body: {"url": url});
  }
}
