class Response<T> {
  final T data;
  final String status;
  final String error;
  final Map<String, List<String>> errors;

  Response(this.status, {this.data, this.error, this.errors});

  bool get isError => status == "error";
}

class ApiInfo {
  final String staticContent;
  final String gameVersion;
  final int turnDelta;
  final int accountId;
  final String accountName;

  ApiInfo(this.staticContent, this.gameVersion, this.turnDelta, this.accountId,
      this.accountName);
}

class ThirdPartyLink {
  final String authorizationPage;

  ThirdPartyLink(this.authorizationPage);
}

class ThirdPartyStatus {
  final String url;
  final int accountId;
  final String accountName;
  final double expireAt;
  final int state;

  ThirdPartyStatus(
      this.url, this.accountId, this.accountName, this.expireAt, this.state);

  bool get isAccepted => state == 2;
}

class GameInfo {
  final String mode;
  final Turn turn;
  final int gameState;
  final int mapVersion;
  final Account account;
  final Account enemy;

  GameInfo(this.mode, this.turn, this.gameState, this.mapVersion, this.account, this.enemy);
}

class Turn {
  final int number;
  final String verboseDate;
  final String verboseTime;

  Turn(this.number, this.verboseDate, this.verboseTime);
}

class Account {
  final int newMessages;
  final int id;
  final int lastVisit;
  final bool isOwn;
  final bool isOld;
  final Hero hero;
  final bool inPvpQueue;
  final int energy;

  Account(this.newMessages, this.id, this.lastVisit, this.isOwn, this.isOld, this.hero, this.inPvpQueue, this.energy);
}

class Hero {
  final int patchTurn;
  // final Equipment equipment;
  final Companion companion;
  final Base base;
  final Secondary secondary;
  final String diary;
  final List<List<dynamic>> messages;

  Hero(this.patchTurn, this.companion, this.base, this.secondary, this.diary, this.messages);
}

class Companion {
  final int type;
  final String name;
  final int health;
  final int maxHealth;
  final int experience;
  final int experienceToLevel;
  final int coherence;
  final int realCoherence;

  Companion(this.type, this.name, this.health, this.maxHealth, this.experience, this.experienceToLevel, this.coherence, this.realCoherence);
}

class Base {
  final int experience;
  final int race;
  final int health;
  final String name;
  final int level;
  final int gender;
  final int experienceToLevel;
  final int maxHealth;
  final int destinyPoints;
  final int money;
  final bool isAlive;

  Base(this.experience, this.race, this.health, this.name, this.level, this.gender, this.experienceToLevel, this.maxHealth, this.destinyPoints, this.money, this.isAlive);
}

class Secondary {
  final int maxBagSize;
  final List<int> power;
  final double moveSpeed;
  final int lootItemsCount;
  final double initiative;

  Secondary(this.maxBagSize, this.power, this.moveSpeed, this.lootItemsCount, this.initiative);
}