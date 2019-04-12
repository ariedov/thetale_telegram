import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/room/action.dart';
import 'package:epictale_telegram/tale_api/tale_api.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';

class ActionRouter {
  ActionRouter(this._userManager, this._taleApi, this._telegramApi);

  final UserManager _userManager;
  final TaleApi _taleApi;
  final TelegramApi _telegramApi;

  Action route(String action) {
    switch (action) {
      case "/start":
        return StartAction(_userManager, _taleApi, _telegramApi);
      case "/auth":
        return RequestAuthAction(_userManager, _taleApi, _telegramApi);
      case "/confirm":
        return ConfirmAuthAction(_userManager, _taleApi, _telegramApi);
      case "/info":
        return InfoAction(_userManager, _taleApi, _telegramApi);
      case "/help":
        return HelpAction(_userManager, _taleApi, _telegramApi);
      case "/add":
        return AddAccountAction(_userManager, _taleApi, _telegramApi);
      case "/remove":
        return RemoveAccountAction(_userManager, _taleApi, _telegramApi);
      default:
        throw "Action $action not supported";
    }
  }
}