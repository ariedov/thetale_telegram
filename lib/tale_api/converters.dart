import 'package:epictale_telegram/tale_api/models.dart';

ThirdPartyLink convertThirdPartyLink(dynamic json) {
  return ThirdPartyLink(
    json["authorisation_page"] as String
  );
}