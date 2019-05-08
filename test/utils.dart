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
