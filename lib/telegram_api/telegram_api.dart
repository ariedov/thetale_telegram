import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:epictale_telegram/telegram_api/converters.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:http/http.dart' as http;

String get token => Platform.environment['TELEGRAM_BOT_ID'];

Future<void> setupWebHook(String url) async {
  return http.post("https://api.telegram.org/bot$token/setWebhook",
      body: {"url": url});
}

class TelegramApi {
  final int chatId;

  TelegramApi(this.chatId);

  Future<Message> sendMessage(String message, {ReplyKeyboard keyboard}) async {
    final response = await http
        .post("https://api.telegram.org/bot$token/sendMessage", body: {
      "chat_id": chatId.toString(),
      "text": message,
      "reply_markup": keyboard != null ? encodeKeyboard(keyboard) : "",
    });

    print("Send message body: ${response.body}");
    return convertMessageAction(json.decode(response.body));
  }
}

String encodeKeyboard(ReplyKeyboard keyboard) {
  return json.encode(keyboard,
      toEncodable: (object) => {
            "keyboard": object.keyboard,
            "resize_keyboard": object.resizeKeyboard
          });
}
