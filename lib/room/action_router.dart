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
import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:thetale_api/thetale_api.dart';

class ActionRouter {
  ActionRouter(this._userManager, this._taleApi);

  final UserManager _userManager;
  final TaleApiWrapper _taleApi;

  TelegramAction route(ChatInfo chatInfo, TelegramWrapper telegram, String action) {
    switch (action) {
      case StartAction.name:
        return StartAction(_userManager, chatInfo, _taleApi, telegram);
      case RequestAuthAction.name:
        return RequestAuthAction(_userManager, chatInfo, _taleApi, telegram);
      case ConfirmAuthAction.name:
        return ConfirmAuthAction(chatInfo, _taleApi, telegram);
      case InfoAction.name:
        return InfoAction(chatInfo, _taleApi, telegram);
      case HelpAction.name:
        return HelpAction(chatInfo, _taleApi, telegram);
      case AddAccountAction.name:
        return AddAccountAction(chatInfo, _taleApi, telegram);
      case RemoveAccountAction.name:
        return RemoveAccountAction(_userManager, chatInfo, _taleApi, telegram);
      case CardsAction.name:
        return CardsAction(chatInfo, _taleApi, telegram);
      case ReceiveCardsAction.name:
        return ReceiveCardsAction(chatInfo, _taleApi, telegram);
      default:
        throw Exception("Action $action not supported");
    }
  }
}