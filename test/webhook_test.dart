import 'dart:convert';

import 'package:epictale_telegram/telegram_api/converters.dart';
import "package:test/test.dart";

void main() {
  test('test parsing update', () {
    const payload =
        """
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

  test("Send message response converter", () {
    const payload = """{"ok":true,"result":{"message_id":17,"from":{"id":663762224,"is_bot":true,"first_name":"EpicTaleBot","username":"EpicTaleBot"},"chat":{"id":123152703,"first_name":"David","last_name":"Leibovych","username":"ariedov","type":"private"},"date":1541109647,"text":"I have received your message!"}}""";
    final message = convertMessageAction(json.decode(payload));
    expect(message.messageId, 17);
  });
}
