import 'dart:async';
import 'dart:convert';
import 'package:epictale_telegram/telegram_api/converters.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:http/http.dart' as http;

const String token = "663762224:AAEatW0mX8svEAZdgGpMOdGJZYXKIasONNc";

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
      "reply_markup": keyboard != null ? "\{\"keyboard\": [[${_buildReplyKeyboardString(keyboard)}]]}" : "",
    });

    print("Send message body: ${response.body}");
    return convertMessageAction(json.decode(response.body));
  }

  String _buildReplyKeyboardString(ReplyKeyboard keyboard) {
    return keyboard.keyboard.map((item) => "\"${item.text}\"").join(", ");
  }
}
