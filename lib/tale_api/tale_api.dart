import 'dart:async';
import 'dart:convert';
import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/tale_api/converters.dart';
import 'package:epictale_telegram/tale_api/models.dart';
import 'package:http/http.dart' as http;

const String applicationId = "epic_tale_telegram";
const String applicationName = "Сказка в Телеграмме";
const String applicationInfo = "Телеграм бот для игры в сказку";
const String applicationDescription = "Телеграм бот для игры в сказку";

class TaleApi {

  final String apiUrl = "https://the-tale.org/";
  final UserManager userManager;

  TaleApi(this.userManager);

  Future<ThirdPartyLink> auth() async {
    const method = "/accounts/third-party/tokens/api/request-authorisation";
    final response = await http.post("$apiUrl$method?api_version=1.0&api_client=$applicationId", body: {
      "application_name": applicationName,
      "application_info": applicationInfo,
      "application_description": applicationDescription
    });
    
    await userManager.saveUserToken(response.headers["Cookie"]);

    final bodyJson = json.decode(response.body);
    final taleResponse = convertResponse(bodyJson, convertThirdPartyLink);
    if (taleResponse.isError) {
      throw taleResponse.error ?? "Что-то пошло не так";
    }
    return taleResponse.data;
  }
}