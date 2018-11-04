import 'dart:async';
import 'dart:convert';
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
  final String apiUrl = "https://the-tale.org";
  final UserManager userManager;

  TaleApi(this.userManager);

  Future<ApiInfo> apiInfo() async {
    const method = "/api/info";
    final response = await http.get(
        "$apiUrl/$method?api_version=1.0&api_client=$applicationId-$appVersion");

    print("Headers: ${response.headers}");
    print("Body: ${response.body}");

    await _processHeader(response.headers);
    return _processResponse<ApiInfo>(response.body, convertApiInfo);
  }

  Future _processHeader(Map<String, String> headers) async {
    final setCookie = headers["set-cookie"];
    print("Set Cookie: $setCookie");

    final session = readSessionInfo(setCookie);
    print("csrftoken: ${session.csrfToken}. sessionId: ${session.sessionId}");

    await userManager.saveUserSession(session);
  }

  Future<ThirdPartyLink> auth() async {
    const method = "/accounts/third-party/tokens/api/request-authorisation";

    final response = await http.post(
        "$apiUrl/$method?api_version=1.0&api_client=$applicationId-$appVersion",
        headers: await _createHeaders(),
        body: {
          "application_name": applicationName,
          "application_info": applicationInfo,
          "application_description": applicationDescription,
        });

    return _processResponse<ThirdPartyLink>(
        response.body, convertThirdPartyLink);
  }

  Future<ThirdPartyStatus> authStatus() async {
    const method = "/accounts/third-party/tokens/api/authorisation-state";

    final response = await http.get(
        "$apiUrl/$method?api_version=1.0&api_client=$applicationId-$appVersion",
        headers: await _createHeaders());

    await _processHeader(response.headers);
    return _processResponse(response.body, convertThirdPartyStatus);
  }

  Future<GameInfo> gameInfo() async {
    const method = "/game/api/info";
    final response = await http.get(
        "$apiUrl/$method?api_version=1.9&api_client=$applicationId-$appVersion",
        headers: await _createHeaders());

    return _processResponse(response.body, convertGameInfo);
  }

  Future<Map<String, String>> _createHeaders() async {
    final session = await userManager.readUserSession();
    return {
      "Referer": apiUrl,
      "X-CSRFToken": session.csrfToken,
      "Cookie":
          "csrftoken=${session.csrfToken}; sessionid=${session.sessionId}",
    };
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

SessionInfo readSessionInfo(String cookie) {
  final sessionRegex = RegExp(r"sessionid=(\w+);");

  final sessionMatch = sessionRegex.firstMatch(cookie);
  String session;
  if (sessionMatch != null) {
    session = sessionMatch.group(1);
  }

  final csrfRegex = RegExp(r"csrftoken=(\w+);");

  final csrfMatch = csrfRegex.firstMatch(cookie);
  String csrf;
  if (csrfMatch != null) {
    csrf = csrfMatch.group(1);
  }

  return SessionInfo(session, csrf);
}
