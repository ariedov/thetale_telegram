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
      _getDouble(json["session_expire_at"]),
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
      _getDouble(json["last_visit"]),
      json["is_own"] as bool,
      json["is_old"] as bool,
      convertHero(json["hero"]),
      json["in_pvp_queue"] as bool,
      json["energy"] as int);
}

Hero convertHero(dynamic json) {
  return Hero(
    _getInt(json["patch_turn"]),
    convertCompanion(json["companion"]),
    convertBase(json["base"]),
    convertSecondary(json["secondary"]),
    _getInt(json["diary"]),
    json["messages"] as List<dynamic>,
    convertAction(json["action"]),
  );
}

Companion convertCompanion(dynamic json) {
  if (json == null) {
    return null;
  }

  return Companion(
    (json["type"] as num).toInt(),
    json["name"] as String,
    _getInt(json["health"]),
    _getInt(json["max_health"]),
    _getInt(json["experience"]),
    _getInt(json["experience_to_level"]),
    _getInt(json["coherence"]),
    _getInt(json["real_coherence"]),
  );
}

Base convertBase(dynamic json) {
  return Base(
    _getInt(json["experience"]),
    _getInt(json["race"]),
    _getInt(json["health"]),
    json["name"] as String,
    _getInt(json["level"]),
    _getInt(json["gender"]),
    _getInt(json["experience_to_level"]),
    _getInt(json["max_health"]),
    _getInt(json["destiny_points"]),
    _getInt(json["money"]),
    json["alive"] as bool,
  );
}

Secondary convertSecondary(dynamic json) {
  if (json == null) {
    return null;
  }

  return Secondary(
    _getInt(json["max_bag_size"]),
    json["power"] as List<dynamic>,
    _getDouble(json["move_speed"]),
    _getInt(json["loot_items_count"]),
    _getDouble(json["initiative"]),
  );
}

Action convertAction(dynamic json) {
  if (json == null) {
    return null;
  }

  return Action(
    _getDouble(json["percents"]),
    json["description"] as String,
    json["info_link"] as String,
    json["type"] as int,
  );
}

PendingOperation convertOperation(dynamic json) {
  return PendingOperation(
    json["status"] as String,
    json["status_url"] as String,
    json["error"] as String,
  );
}

typedef Converter<T> = T Function(dynamic json);

int _getInt(dynamic value) {
  if (value != null && value is num) {
    return value.toInt();
  }
  return 0;
}

double _getDouble(dynamic value) {
  if (value != null && value is num) {
    return value.toDouble();
  }
  return 0.0;
}