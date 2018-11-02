import 'dart:convert';

import 'package:epictale_telegram/tale_api/converters.dart';
import 'package:test/test.dart';

void main() {
  test("test parse error", () {
    const payload = """{
      "code": "common.csrf",
      "status": "error",
      "error": "Неверный csrf токен. Если Вы обычный игрок, возможно, Вы случайно разлогинились — обновите страницу и снова войдите в игру. Если Вы разработчик, проверьте формирование своего запроса. []"
    }""";

    final payloadJson = json.decode(payload);
    final response = convertResponse(payloadJson, convertThirdPartyLink);
    
    expect(response.isError, true);
  });
}
