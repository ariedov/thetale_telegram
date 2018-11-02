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

  test("test api info", () {
    const payload = """{
      "status": "ok",
      "data": {
          "account_name": null,
          "account_id": null,
          "abilities_cost": {
              "arena_pvp_1x1": 1,
              "arena_pvp_1x1_accept": 1,
              "arena_pvp_1x1_leave_queue": 0,
              "help": 4,
              "drop_item": 1
          },
          "game_version": "v0.3.27.1",
          "static_content": "//static.the-tale.org/static/247/",
          "turn_delta": 10
      }
    }""";

    final payloadJson = json.decode(payload);
    final response = convertResponse(payloadJson, convertApiInfo);

    expect(response.status, "ok");
    expect(response.data.gameVersion, "v0.3.27.1");
  });
}
