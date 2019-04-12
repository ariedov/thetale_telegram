import 'dart:async';
import 'dart:convert';
import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/tale_api/converters.dart';
import 'package:epictale_telegram/tale_api/models.dart';
import 'package:http/http.dart' as http;

const String appVersion = "0.0.1";

const String apiUrl = "https://the-tale.org";

const String applicationId = "epic_tale_telegram";
const String applicationName = "Сказка в Телеграмме";
const String applicationInfo = "Телеграм бот для игры в сказку";
const String applicationDescription = "Телеграм бот для игры в сказку";

class TaleApi {
  TaleApi();

  Future<SessionDataPair<ApiInfo>> apiInfo() async {
    const method = "/api/info";
    final response = await http.get(
        "$apiUrl/$method?api_version=1.0&api_client=$applicationId-$appVersion");

    print("Headers: ${response.headers}");
    print("Body: ${response.body}");

    return SessionDataPair(readSessionFromHeader(response.headers),
        _processResponse<ApiInfo>(response.body, convertApiInfo));
  }

  Future<ThirdPartyLink> auth({Map<String, String> headers}) async {
    const method = "/accounts/third-party/tokens/api/request-authorisation";

    final response = await http.post(
        "$apiUrl/$method?api_version=1.0&api_client=$applicationId-$appVersion",
        headers: headers,
        body: {
          "application_name": applicationName,
          "application_info": applicationInfo,
          "application_description": applicationDescription,
        });

    return _processResponse<ThirdPartyLink>(
        response.body, convertThirdPartyLink);
  }

  Future<SessionDataPair<ThirdPartyStatus>> authStatus(
      {Map<String, String> headers}) async {
    const method = "/accounts/third-party/tokens/api/authorisation-state";

    final response = await http.get(
        "$apiUrl/$method?api_version=1.0&api_client=$applicationId-$appVersion",
        headers: headers);

    return SessionDataPair(readSessionFromHeader(response.headers),
        _processResponse(response.body, convertThirdPartyStatus));
  }

  Future<GameInfo> gameInfo({Map<String, String> headers}) async {
    const method = "/game/api/info";
    final response = await http.get(
        "$apiUrl/$method?api_version=1.9&api_client=$applicationId-$appVersion",
        headers: headers);

    return _processResponse(response.body, convertGameInfo);
  }

  Future<PendingOperation> help({Map<String, String> headers}) async {
    const method = "/game/abilities/help/api/use";
    final response = await http.post(
        "$apiUrl/$method?api_version=1.0&api_client=$applicationId-$appVersion",
        headers: headers);

    final operation = convertOperation(json.decode(response.body));
    if (operation.isError) {
      throw operation.error;
    }
    return operation;
  }

  Future<PendingOperation> checkOperation(String pendingUrl,
      {Map<String, String> headers}) async {
    final response = await http.get("$apiUrl/$pendingUrl", headers: headers);

    return _processResponse(response.body, convertOperation);
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

SessionInfo readSessionFromHeader(Map<String, String> headers) {
  final cookie = headers["set-cookie"];
  print("Set Cookie: $cookie");
  return readSessionInfo(cookie);
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

class SessionDataPair<T> {
  SessionDataPair(this.sessionInfo, this.data);

  final SessionInfo sessionInfo;
  final T data;
}
