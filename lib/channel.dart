import 'package:epictale_telegram/api/telegram_api.dart';
import 'package:epictale_telegram/webhook_controller.dart';

import 'epictale_telegram.dart';

const String appToken = "663762224:AAEatW0mX8svEAZdgGpMOdGJZYXKIasONNc";

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class EpictaleTelegramChannel extends ApplicationChannel {
  
  TelegramApi api;

  EpictaleTelegramChannel() {
    api = TelegramApi(appToken);
  }

  @override
  Future prepare() async {
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    await api.setupWebHook("https://epictale-telegram.herokuapp.com/$appToken");
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    router
      .route(appToken)
      .link(() => WebhookController());

    return router;
  }
}