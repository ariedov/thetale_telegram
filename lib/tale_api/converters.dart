import 'package:epictale_telegram/tale_api/models.dart';

Response<T> convertResponse<T>(dynamic json, Converter<T> converter) {
  return Response<T>(
    json["status"] as String,
    data: json["data"] != null ? converter(json["data"]) : null,
    error: json["error"] as String,
  );
}

ThirdPartyLink convertThirdPartyLink(dynamic json) {
  return ThirdPartyLink(json["authorisation_page"] as String);
}

ThirdPartyStatus convertThirdPartyStatus(dynamic json) {
  return ThirdPartyStatus(
      json["next_url"] as String,
      json["account_id"] as int,
      json["account_name"] as String,
      json["session_expire_at"] as double,
      json["state"] as int);
}

ApiInfo convertApiInfo(dynamic json) {
  return ApiInfo(
      json["static_content"] as String,
      json["game_version"] as String,
      json["turn_delta"] as int,
      json["account_id"] as int,
      json["account_name"] as String);
}

GameInfo convertGameInfo(dynamic json) {
  return GameInfo(
    json["mode"] as String,
    convertTurn(json["turn"]),
    json["game_state"] as int,
    json["map_version"] as String,
    convertAccount(json["account"]),
    convertAccount(json["enemy"]),
  );
}

Turn convertTurn(dynamic json) {
  return Turn(json["number"] as int, json["verbose_date"] as String,
      json["verbose_time"] as String);
}

Account convertAccount(dynamic json) {
  if (json == null) {
    return null;
  }

  return Account(
      json["new_messages"] as int,
      json["id"] as int,
      json["last_visit"] as double,
      json["is_own"] as bool,
      json["is_old"] as bool,
      convertHero(json["hero"]),
      json["in_pvp_queue"] as bool,
      json["energy"] as int);
}

Hero convertHero(dynamic json) {
  return Hero(
    json["patch_turn"] as int,
    convertCompanion(json["companion"]),
    convertBase(json["base"]),
    convertSecondary(json["secondary"]),
    json["diary"] as int,
    json["messages"] as List<dynamic>,
  );
}

Companion convertCompanion(dynamic json) {
  if (json == null) {
    return null;
  }

  return Companion(
    json["type"] as int,
    json["name"] as String,
    json["health"] as int,
    json["max_health"] as int,
    json["experience"] as int,
    json["experience_to_level"] as int,
    json["coherence"] as int,
    json["real_coherence"] as int,
  );
}

Base convertBase(dynamic json) {
  return Base(
    json["experience"] as int,
    json["race"] as int,
    json["health"] as int,
    json["name"] as String,
    json["level"] as int,
    json["gender"] as int,
    json["experience_to_level"] as int,
    json["max_health"] as int,
    json["destiny_points"] as int,
    json["money"] as int,
    json["alive"] as bool,
  );
}

Secondary convertSecondary(dynamic json) {
  if (json == null) {
    return null;
  }

  return Secondary(
    json["max_bag_size"] as int,
    json["power"] as List<dynamic>,
    json["move_speed"] as double,
    json["loot_items_count"] as int,
    json["initiative"] as double,
  );
}

PendingOperation convertOperation(dynamic json) {
  return PendingOperation(
    json["status"] as String,
    json["status_url"] as String,
  );
}

typedef Converter<T> = T Function(dynamic json);
