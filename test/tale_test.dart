import 'dart:convert';

import 'package:epictale_telegram/tale_api/converters.dart';
import 'package:epictale_telegram/tale_api/tale_api.dart';
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

  test("test third party", () {
    const payload = """{
      "status": "ok",
      "data": {
          "authorisation_page": "/accounts/third-party/tokens/41b21f95-8b4f-41f0-acef-e5ca06edcaf0"
      }
    }""";

    final payloadJson = json.decode(payload);
    final response = convertResponse(payloadJson, convertThirdPartyLink);

    expect(response.isError, false);
    expect(response.data.authorizationPage,
        "/accounts/third-party/tokens/41b21f95-8b4f-41f0-acef-e5ca06edcaf0");
  });

  test("test auth status", () {
    const payload = """{
      "status": "ok",
      "data": {
          "account_name": null,
          "account_id": null,
          "state": 0,
          "session_expire_at": 1542405235
      }
    }""";

    final payloadJson = json.decode(payload);
    final response = convertResponse(payloadJson, convertThirdPartyStatus);

    expect(response.isError, false);
    expect(response.data.expireAt, 1542405235);
  });

  test("test headers read", () {
    const payload = """
        sessionid=csxqqjj7cyiy9b3mukhzor9z9we9twks; expires=Fri, 16-Nov-2018 16:15:22 GMT; HttpOnly; Max-Age=1209600; Path=/; Secure,csrftoken=PVw6ZDIEt2UfcxsWwtdAES9Mwlq7FH7bxoyJMw1YlIj7wc3WhB0rKt6aRhzOkrOk; expires=Fri, 01-Nov-2019 16:15:22 GMT; HttpOnly; Max-Age=31449600; Path=/; Secure""";

    final session = readSessionInfo(payload);

    expect(session.sessionId, "csxqqjj7cyiy9b3mukhzor9z9we9twks");
    expect(session.csrfToken,
        "PVw6ZDIEt2UfcxsWwtdAES9Mwlq7FH7bxoyJMw1YlIj7wc3WhB0rKt6aRhzOkrOk");
  });
}
