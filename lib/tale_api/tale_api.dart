import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/tale_api/converters.dart';
import 'package:epictale_telegram/tale_api/models.dart';
import 'package:http/http.dart' as http;

const String appVersion = "0.0.1";

const String applicationId = "epic_tale_telegram";
const String applicationName = "Сказка в Телеграмме";
const String applicationInfo = "Телеграм бот для игры в сказку";
const String applicationDescription = "Телеграм бот для игры в сказку";

class TaleApi {
  final String apiUrl = "https://the-tale.org/";
  final UserManager userManager;

  TaleApi(this.userManager);

  Future<ApiInfo> apiInfo() async {
    const method = "/api/info";
    final response = await http.post(
        "$apiUrl/$method?api_version=1.9&api_client=$applicationId-$appVersion");

    print("Headers: ${response.headers}");
    print("Body: ${response.body}");

    await _processHeader(response.headers);
    return _processResponse<ApiInfo>(response.body, convertApiInfo);
  }

  Future _processHeader(Map<String, String> headers) async {
    final setCookie = headers["set-cookie"];
    print("Set Cookie: $setCookie");

    final cookies = setCookie.split("; ");
    final csrfToken = cookies.firstWhere((text) => text.contains("csrftoken"));
    final sessionid = cookies.firstWhere((text) => text.contains("sessionid"),
        orElse: () => null);
    await userManager.saveUserSession(SessionInfo(csrfToken, sessionid));

    print("csrftoken: $csrfToken. sessionId: $sessionid");
  }

  Future<ThirdPartyLink> auth() async {
    const method = "/accounts/third-party/tokens/api/request-authorisation";
    final session = await userManager.readUserSession();

    final response = await http.post(
        "$apiUrl$method?api_version=1.0&api_client=$applicationId",
        headers: {
          "Referer": apiUrl,
          "X-CSRFToken": session.csrfToken,
          "sessionid": session.sessionId
        },
        body: {
          "application_name": applicationName,
          "application_info": applicationInfo,
          "application_description": applicationDescription
        });

    return _processResponse<ThirdPartyLink>(
        response.body, convertThirdPartyLink);
  }

  T _processResponse<T>(String body, T converter(dynamic json)) {
    final bodyJson = json.decode(body);
    final taleResponse = convertResponse(bodyJson, converter);

    if (taleResponse.isError) {
      throw taleResponse.error ?? "Что-то пошло не так";
    }
    return taleResponse.data;
  }
}
