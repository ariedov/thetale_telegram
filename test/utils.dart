import 'package:thetale_api/thetale_api.dart';

Card buildCard(
    {bool inStorage = false,
    String name = "",
    String fullType = "1",
    int rarity = 1,
    String uid = "",
    int type = 1,
    bool auction = false}) {
  return Card(inStorage, name, fullType, rarity, uid, type, auction);
}

GameInfo createGameInfoWithCharacterName(String character) {
//  info.account?.hero?.base?.name
  return GameInfo(
      "",
      null,
      null,
      null,
      Account(
          null,
          null,
          null,
          true,
          false,
          Hero(
              null,
              null,
              Base(null, null, null, character, null, null, null, null, null,
                  null, true),
              null,
              null,
              null,
              null),
          false,
          100),
      null);
}