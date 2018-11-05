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
          "session_expire_at": 1542405235.0
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

  test("test session headers read", () {
    const payload = """
        sessionid=csxqqjj7cyiy9b3mukhzor9z9we9twks; expires=Fri, 16-Nov-2018 16:15:22 GMT; HttpOnly; Max-Age=1209600; Path=/; Secure,""";

    final session = readSessionInfo(payload);

    expect(session.sessionId, "csxqqjj7cyiy9b3mukhzor9z9we9twks");
    expect(session.csrfToken, null);
  });

  test("test csrf headers read", () {
    const payload = """
        csrftoken=PVw6ZDIEt2UfcxsWwtdAES9Mwlq7FH7bxoyJMw1YlIj7wc3WhB0rKt6aRhzOkrOk; expires=Fri, 01-Nov-2019 16:15:22 GMT; HttpOnly; Max-Age=31449600; Path=/; Secure""";

    final session = readSessionInfo(payload);

    expect(session.sessionId, null);
    expect(session.csrfToken,
        "PVw6ZDIEt2UfcxsWwtdAES9Mwlq7FH7bxoyJMw1YlIj7wc3WhB0rKt6aRhzOkrOk");
  });

  test("test game info", () {
    const payload =
        """{"enemy": null, "mode": "pve", "map_version": "19941122-1541366434.289256", "turn": {"number": 19941332, "verbose_date": "2 юного квинта сырого месяца 213 года", "verbose_time": "19:32"}, "game_state": 1, "account": {"id": 29620, "hero": {"id": 29620, "bag": {"42755": {"id": 124, "special_effect": 666, "equipped": false, "preference_rating": null, "effect": 666, "type": 0, "integrity": [null, null], "name": "шарик белого скарабея", "rarity": null, "power": null}, "42750": {"id": 300, "special_effect": 666, "equipped": true, "preference_rating": 18.0, "effect": 666, "type": 4, "integrity": [11092, 11092], "name": "лёгкий коготь", "rarity": 0, "power": [25, 11]}}, "secondary": {"loot_items_count": 2, "initiative": 1.0, "max_bag_size": 14.0, "move_speed": 0.3597000000000001, "power": [255, 334]}, "quests": {"quests": [{"line": [{"choice": null, "type": "next-spending", "actors": [["цель", 2, {"goal": "изменение влияния", "description": "Планирует накопить деньжат, чтобы повлиять на «запомнившегося» горожанина."}]], "name": "Накопить золото", "uid": "next-spending", "choice_alternatives": [], "power": 0, "action": "копит", "experience": 0}]}, {"line": [{"choice": null, "type": "collect_debt", "actors": [["кредитор", 0, {"id": 1923, "place": 21, "race": 4, "name": "Эдит", "personality": {"practical": 9, "cosmetic": 9}, "profession": 15, "gender": 1}], ["должник", 0, {"id": 3377, "place": 6, "race": 2, "name": "Алтан", "personality": {"practical": 14, "cosmetic": 5}, "profession": 6, "gender": 1}]], "name": "Напомнить о невыплаченном долге", "uid": "[ns-0]start", "choice_alternatives": [], "power": 496, "action": "возвращается, чтобы решить дело силой", "experience": 86}]}]}, "habits": {"honor": {"raw": 2.0, "verbose": "себе на уме"}, "peacefulness": {"raw": 980.9861111111238, "verbose": "гуманист"}}, "actual_on_turn": 19941332, "base": {"gender": 0, "experience": 3759, "race": 2, "destiny_points": 0, "level": 36, "name": "Сурен", "money": 507, "max_health": 2250, "experience_to_level": 5140, "alive": true, "health": 1970}, "companion": {"coherence": 69, "real_coherence": 69, "type": 162, "experience_to_level": 70, "name": "Кобыла", "experience": 49, "health": 285, "max_health": 300}, "patch_turn": null, "might": {"pvp_effectiveness_bonus": 0.07516806730504211, "crit_chance": 0.30067226922016843, "politics_power": 0.30067226922016843, "value": 1015.6}, "equipment": {"3": {"id": 56, "special_effect": 666, "equipped": true, "preference_rating": 29.0, "effect": 666, "type": 7, "integrity": [11068, 11128], "name": "пламенный воротник", "rarity": 0, "power": [23, 35]}, "1": {"id": 142, "special_effect": 666, "equipped": true, "preference_rating": 26.0, "effect": 666, "type": 2, "integrity": [12472, 12571], "name": "гербовый щит", "rarity": 0, "power": [27, 25]}, "4": {"id": 27, "special_effect": 666, "equipped": true, "preference_rating": 29.5, "effect": 666, "type": 3, "integrity": [11363, 11367], "name": "химический доспех", "rarity": 0, "power": [28, 31]}, "2": {"id": 70, "special_effect": 666, "equipped": true, "preference_rating": 38.0, "effect": 1005, "type": 5, "integrity": [20692, 20697], "name": "цервельер", "rarity": 2, "power": [17, 21]}, "5": {"id": 317, "special_effect": 666, "equipped": true, "preference_rating": 21.0, "effect": 666, "type": 8, "integrity": [12673, 12685], "name": "гомункуловые перчатки", "rarity": 0, "power": [31, 11]}, "7": {"id": 1, "special_effect": 666, "equipped": true, "preference_rating": 25.5, "effect": 666, "type": 9, "integrity": [9618, 9767], "name": "портки", "rarity": 0, "power": [29, 22]}, "9": {"id": 66, "special_effect": 666, "equipped": true, "preference_rating": 29.0, "effect": 666, "type": 4, "integrity": [13525, 13603], "name": "пергамент", "rarity": 0, "power": [22, 36]}, "0": {"id": 48, "special_effect": 666, "equipped": true, "preference_rating": 21.0, "effect": 666, "type": 1, "integrity": [11743, 11802], "name": "рунный топор", "rarity": 0, "power": [22, 20]}, "10": {"id": 172, "special_effect": 666, "equipped": true, "preference_rating": 25.0, "effect": 666, "type": 11, "integrity": [9273, 9304], "name": "угольное кольцо", "rarity": 0, "power": [9, 41]}, "6": {"id": 215, "special_effect": 666, "equipped": true, "preference_rating": 25.0, "effect": 666, "type": 6, "integrity": [12129, 12143], "name": "теневой плащ", "rarity": 0, "power": [18, 32]}, "8": {"id": 271, "special_effect": 666, "equipped": true, "preference_rating": 25.5, "effect": 666, "type": 10, "integrity": [10414, 10552], "name": "виринки", "rarity": 0, "power": [10, 41]}}, "action": {"is_boss": null, "type": 8, "data": null, "info_link": null, "description": "дико тараторя, торгуется", "percents": 0.8}, "permissions": {"can_participate_in_pvp": true, "can_repair_building": false}, "diary": 3683, "ui_caching_started_at": 1541368397.0, "messages": [[1541368485.180022, "19:28", "После обмена серией стремительных ударов с Суреном, белый скарабей наконец нашёл брешь в защите и нанёс удар.", 280003, {"attacker": "белый скарабей", "defender": "Сурен", "damage": "33", "date": "2 юного квинта сырого месяца 213 года", "defender.weapon": "рунный топор", "attacker.weapon": "жвалы", "time": "19:28"}], [1541368495.1951637, "19:29", "Издавая зловещие звуки, Сурен сжимает белого скарабея что есть силы в своих объятиях!", 280003, {"attacker": "Сурен", "defender": "белый скарабей", "damage": "86", "date": "2 юного квинта сырого месяца 213 года", "defender.weapon": "жвалы", "attacker.weapon": "рунный топор", "time": "19:29"}], [1541368495.1956747, "19:29", "Победителю — слава, проигравшему — смерть! Сурен стоит над останками сражённого белого скарабея.", 8, {"mob.weapon": "жвалы", "hero": "Сурен", "mob": "белый скарабей", "hero.weapon": "рунный топор", "date": "2 юного квинта сырого месяца 213 года", "time": "19:29"}], [1541368495.196445, "19:29", "«Превосходно, вот и трофеями судьба не обделила», — думает Сурен, убирая шарик белого скарабея в рюкзак.", 13, {"mob.weapon": "жвалы", "hero": "Сурен", "mob": "белый скарабей", "hero.weapon": "рунный топор", "date": "2 юного квинта сырого месяца 213 года", "artifact": "шарик белого скарабея", "time": "19:29"}], [1541368505.2138603, "19:30", "На воротах Оркостана был затор. Толпа горожан и путников создавали невероятный шум. Гоблин купец ругал начальника караула и не хотел платить какие-то пошлины за вывоз, начальник в ответ грозился купца «зарестовать». Старуха дварфийка совала другому стражнику индюка «с благодарностию за охрану», тот взять хотел, но ему мешала эльфка, желавшая немедленно узнать, не покидала ли города этой ночью распутного вида девица в сопровождении богатого господина. Орки, пригнавшие в город скот на продажу, ссорились с группой пилигримов, двигавшихся в противоположном направлении. Где-то лаяла собака и плакал ребёнок...  Сурен, вздохнув, встал в очередь, медленно двигавшуюся к воротам.", 80036, {"hero": "Сурен", "place": "Оркостан", "date": "2 юного квинта сырого месяца 213 года", "hero.weapon": "рунный топор", "time": "19:30"}], [1541368505.2144911, "19:30", "Направился в конюшни Оркостана и приобрёл там хорошего овса для верной кобылы.", 80032, {"hero.weapon": "рунный топор", "companion": "кобыла", "hero": "Сурен", "companion.weapon": "копыто", "place": "Оркостан", "date": "2 юного квинта сырого месяца 213 года", "time": "19:30", "coins": "24"}], [1541368505.2154405, "19:30", "Сурен, влечённый разноцветными шатрами рынка, не смог пройти мимо.", 220002, {"hero": "Сурен", "date": "2 юного квинта сырого месяца 213 года", "hero.weapon": "рунный топор", "time": "19:30"}], [1541368505.2159834, "19:30", "Заметив у меня в инвентаре слюну койота, торговец в ужасе отпрянул и заплатил 5 монет за то, чтобы я выкинул эту мерзость подальше.", 220001, {"hero.weapon": "рунный топор", "hero": "Сурен", "coins": "5", "date": "2 юного квинта сырого месяца 213 года", "artifact": "слюна койота", "time": "19:30"}], [1541368515.2740283, "19:31", "«Шакалий хвост стоит не меньше 2 монет! Нет, так я найду другого покупателя!.. То-то же!»", 220001, {"hero.weapon": "рунный топор", "hero": "Сурен", "coins": "2", "date": "2 юного квинта сырого месяца 213 года", "artifact": "шакалий хвост", "time": "19:31"}], [1541368525.2201462, "19:32", "Сурен скептически смотрит на 15 монет, вырученных за кость мертвеца, и, пожимая плечами, убирает деньги в карман.", 220001, {"hero.weapon": "рунный топор", "hero": "Сурен", "coins": "15", "date": "2 юного квинта сырого месяца 213 года", "artifact": "кость мертвеца", "time": "19:32"}]], "position": {"dx": 0, "y": 34, "x": 22, "dy": 0}, "sprite": 8}, "is_own": true, "energy": 4062, "in_pvp_queue": false, "last_visit": 1541366500.0, "is_old": false}}""";

    final jsonPayload = json.decode(payload);
    final gameInfo = convertGameInfo(jsonPayload);
    expect(gameInfo.account.hero.base.name, "Сурен");
  });

  test("test processing operation", () {
    const payload =
        """{"status": "processing", "status_url": "/postponed-tasks/35657544/status"}""";
    final jsonPayload = json.decode(payload);

    final status = convertOperation(jsonPayload);
    expect(status.status, "processing");
    expect(status.statusUrl, "/postponed-tasks/35657544/status");
  });
}
