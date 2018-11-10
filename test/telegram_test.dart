import 'dart:convert';

import 'package:epictale_telegram/telegram_api/converters.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import "package:test/test.dart";

void main() {
  test('test parsing update', () {
    const payload = """
        {
          "update_id": 622582740, 
          "message": 
          {
            "message_id": 6, 
            "from": 
            {
              "id": 123152703, 
              "is_bot": false,
              "first_name": "David", 
              "last_name": "Leibovych", 
              "username": "ariedov", 
              "language_code": "en-UA"
            }, 
            "chat": 
            {
              "id": 123152703, 
              "first_name": "David", 
              "last_name": "Leibovych", 
              "username": "ariedov", 
              "type": "private"
            }, 
            "date": 1541051643, 
            "text": "asdfa"
          }
        }""";

    final update = convertUpdate(json.decode(payload));

    expect(update.updateId, 622582740);
  });

  test("test parsing action", () {
    const payload = """
    {
      "update_id":622582760,
      "message":
      {
        "message_id":35,
        "from":
        {
          "id":123152703,
          "is_bot":false,
          "first_name":"David",
          "last_name":"Leibovych",
          "username":"ariedov",
          "language_code":"ru"
        },
        "chat":
        {
          "id":123152703,
          "first_name":"David",
          "last_name":"Leibovych",
          "username":"ariedov",
          "type":"private"},
          "date":1541160908,
          "text":"/start",
          "entities":[{"offset":0,"length":6,"type":"bot_command"}]
        }
      }""";

    final update = convertUpdate(json.decode(payload));
    expect(update.updateId, 622582760);
    expect(update.message.entities.length, 1);
    expect(update.message.entities[0].type, MessageEntityType.botCommand);
  });

  test("Send message response converter", () {
    const payload =
        """{"ok":true,"result":{"message_id":17,"from":{"id":663762224,"is_bot":true,"first_name":"EpicTaleBot","username":"EpicTaleBot"},"chat":{"id":123152703,"first_name":"David","last_name":"Leibovych","username":"ariedov","type":"private"},"date":1541109647,"text":"I have received your message!"}}""";
    final message = convertMessageAction(json.decode(payload));
    expect(message.messageId, 17);
  });

  test("Keyboard convert", () {
    final keyboard = ReplyKeyboard([
      ["text"]
    ]);

    final encoded = encodeKeyboard(keyboard);
    expect(encoded, "{\"keyboard\":[[\"text\"]],\"resize_keyboard\":true}");
  });

  test("inline convert single", () {
    final keyboard = InlineKeyboard([
      [InlineKeyboardButton("text", "text")],
    ]);

    final encoded = encodeInlineKeyboard(keyboard);
    final decoded = json.decode(encoded);
    expect(decoded["inline_keyboard"][0][0]["text"], "text");
  });

  test("inline convert multiple", () {
    final keyboard = InlineKeyboard([
      [InlineKeyboardButton("text", "text")],
      [InlineKeyboardButton("text", "text")],
    ]);

    final encoded = encodeInlineKeyboard(keyboard);
    final decoded = json.decode(encoded);
    expect(decoded["inline_keyboard"][0][0]["text"], "text");
    expect(decoded["inline_keyboard"][1][0]["text"], "text");
  });

  test("convert update with callback", () {
    const payload = """{"update_id":622582834,
      "callback_query":{"id":"528936832932263427","from":{"id":123152703,"is_bot":false,"first_name":"David","last_name":"Leibovych","username":"ariedov","language_code":"ru"},"message":{"message_id":389,"from":{"id":663762224,"is_bot":true,"first_name":"EpicTaleBot","username":"EpicTaleBot"},"chat":{"id":123152703,"first_name":"David","last_name":"Leibovych","username":"ariedov","type":"private"},"date":1541497717,"text":"\u0427\u0442\u043e\u0431\u044b \u0430\u0432\u0442\u043e\u0440\u0438\u0437\u043e\u0432\u0430\u0442\u044c\u0441\u044f - \u043f\u0435\u0440\u0435\u0439\u0434\u0438 \u043f\u043e \u0441\u0441\u044b\u043b\u043a\u0435 https://the-tale.org/accounts/third-party/tokens/bf767057-329b-412e-a14b-c8b877186fa3","entities":[{"offset":41,"length":85,"type":"url"}]},"chat_instance":"-4947687325066424995","data":"/confirm"}}""";

      final update = convertUpdate(json.decode(payload));
      expect(update.callbackQuery.data, "/confirm");
  });
}
