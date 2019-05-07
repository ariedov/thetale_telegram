import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/room/add_account_action.dart';
import 'package:epictale_telegram/room/cards/new_cards_action.dart';
import 'package:epictale_telegram/room/cards/receive_cards_action.dart';
import 'package:epictale_telegram/room/confirm_auth_action.dart';
import 'package:epictale_telegram/room/help_action.dart';
import 'package:epictale_telegram/room/info_action.dart';
import 'package:epictale_telegram/room/remove_account_action.dart';
import 'package:epictale_telegram/room/request_auth_action.dart';
import 'package:epictale_telegram/room/start_action.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:thetale_api/thetale_api.dart';

class ActionRouter {
  ActionRouter(this._userManager, this._taleApi, this._telegramApi);

  final UserManager _userManager;
  final TaleApiWrapper _taleApi;
  final TelegramApi _telegramApi;

  TelegramAction route(String action) {
    switch (action) {
      case StartAction.name:
        return StartAction(_userManager, _taleApi, _telegramApi);
      case RequestAuthAction.name:
        return RequestAuthAction(_userManager, _taleApi, _telegramApi);
      case ConfirmAuthAction.name:
        return ConfirmAuthAction(_taleApi, _telegramApi);
      case InfoAction.name:
        return InfoAction(_taleApi, _telegramApi);
      case HelpAction.name:
        return HelpAction(_taleApi, _telegramApi);
      case AddAccountAction.name:
        return AddAccountAction(_taleApi, _telegramApi);
      case RemoveAccountAction.name:
        return RemoveAccountAction(_userManager, _taleApi, _telegramApi);
      case NewCardsAction.name:
        return NewCardsAction(_taleApi, _telegramApi);
      case ReceiveCardsAction.name:
        return ReceiveCardsAction(_taleApi, _telegramApi);
      default:
        throw Exception("Action $action not supported");
    }
  }
}