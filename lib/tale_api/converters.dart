import 'package:epictale_telegram/tale_api/models.dart';

Response<T> convertResponse<T>(dynamic json, Converter<T> converter) {
  return Response<T>(
    json["status"] as String,
    data: json["data"] != null ? converter(json["data"]) : null,
    error: json["error"] as String,
  );
}

ThirdPartyLink convertThirdPartyLink(dynamic json) {
  return ThirdPartyLink(
    json["authorisation_page"] as String
  );
}

ThirdPartyStatus convertThirdPartyStatus(dynamic json) {
  return ThirdPartyStatus(
    json["next_url"] as String,
    json["account_id"] as int,
    json["account_name"] as String,
    json["session_expire_at"] as int,
    json["state"] as int
  );
}

ApiInfo convertApiInfo(dynamic json) {
  return ApiInfo(
    json["static_content"] as String,
    json["game_version"] as String,
    json["turn_delta"] as int,
    json["account_id"] as int,
    json["account_name"] as String
  );
}

typedef Converter<T> = T Function(dynamic json);