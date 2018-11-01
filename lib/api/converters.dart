import 'package:epictale_telegram/api/models.dart';

Update convertUpdate(dynamic json) {
  return Update(
    json["update_id"] as int,
    convertMessage(json[""])
  );
}

Message convertMessage(dynamic json) {

}

User convertUser(dynamic json) {

}