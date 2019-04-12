import 'dart:async';
import 'dart:convert';
import 'package:epictale_telegram/constants.dart';
import 'package:epictale_telegram/telegram_api/converters.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:http/http.dart' as http;

Future<void> setupWebHook(String url) async {
  return http.post("https://api.telegram.org/bot$token/setWebhook",
      body: {"url": url});
}

class TelegramApi {
  TelegramApi(this.chatId);

  final int chatId;

  Future<Message> sendMessage(String message,
      {ReplyKeyboard keyboard, InlineKeyboard inlineKeyboard}) async {
    final response = await http
        .post("https://api.telegram.org/bot$token/sendMessage", body: {
      "chat_id": chatId.toString(),
      "text": message,
      "reply_markup": keyboard != null
          ? encodeKeyboard(keyboard)
          : inlineKeyboard != null ? encodeInlineKeyboard(inlineKeyboard) : "",
      "parse_mode": "Markdown",
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

String encodeInlineKeyboard(InlineKeyboard keyboard) {
  return "{\"inline_keyboard\": [${_mapKeyboardInline(keyboard)}]}";
}

String _mapKeyboardInline(InlineKeyboard keyboard) {
  final result = StringBuffer();
  for (var i = 0; i < keyboard.keyboard.length; ++i) {
    final row = keyboard.keyboard[i];
    result.write("[");
    for (var j = 0; j < row.length; ++j) {
      final item = row[j];
      result.write("""{
        "text": "${item.text}",
        "callback_data": "${item.callbackData}"
      }""");
      if (j < row.length - 1) {
        result.write(",");
      }
    }
    result.write("]");
    if (i < keyboard.keyboard.length - 1) {
      result.write(",");
    }
  }
  return result.toString();
}
