import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/tale_api/models.dart';
import 'package:epictale_telegram/tale_api/tale_api.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';

abstract class Action {
  final UserManager _userManager;
  final TaleApi _taleApi;
  final TelegramApi _telegramApi;

  Action(this._userManager, this._taleApi, this._telegramApi);

  Future<void> performAction();

  TaleApi get taleApi => _taleApi;
  TelegramApi get telegramApi => _telegramApi;

  Future<Message> trySendMessage(String message,
      {ReplyKeyboard keyboard, InlineKeyboard inlineKeyboard}) async {
    try {
      return await telegramApi.sendMessage(message,
          keyboard: keyboard, inlineKeyboard: inlineKeyboard);
    } catch (e) {
      print("Failed to send message");
    }
    return null;
  }
}

class StartAction extends Action {
  StartAction(UserManager userManager, TaleApi taleApi, TelegramApi telegramApi)
      : super(userManager, taleApi, telegramApi);

  @override
  Future<void> performAction() async {
    await trySendMessage("Привет, хранитель!");

    await _userManager.setAuthorized(authorized: false);
    final info = await taleApi.apiInfo();
    await processHeader(_userManager, info.sessionInfo);

    await trySendMessage("""
        Версия игры ${info.data.gameVersion}. Сейчас попробую тебя авторизовать.
        /start - начать все по новой
        /auth - снова авторизироваться
        /confirm - подтвердить авторизацию после того как дал доступ боту (мне)

        /help - помочь своему герою
        /info - получить информацию о герое
        """);

    final link = await taleApi.auth(headers: await createHeaders(_userManager));
    await trySendMessage(
      "Чтобы авторизоваться - перейди по ссылке ${apiUrl}${link.authorizationPage}",
      inlineKeyboard: InlineKeyboard([
        [InlineKeyboardButton("/confirm", "/confirm")]
      ]),
    );
  }
}

class ConfirmAuthAction extends Action {
  ConfirmAuthAction(
      UserManager userManager, TaleApi taleApi, TelegramApi telegramApi)
      : super(userManager, taleApi, telegramApi);

  @override
  Future<void> performAction() async {
    final status =
        await taleApi.authStatus(headers: await createHeaders(_userManager));

    final isAuthorized = await _userManager.isAuthorized();
    if (status.data.isAccepted && !isAuthorized) {
      await processHeader(_userManager, status.sessionInfo);
    }

    if (status.data.isAccepted) {
      await trySendMessage("Ну привет, ${status.data.accountName}.",
          keyboard: ReplyKeyboard([
            ["/help"],
            ["/info"],
          ]));

      final gameInfo =
          await _taleApi.gameInfo(headers: await createHeaders(_userManager));
      await trySendMessage(
          """${gameInfo.account.hero.base.name} уже заждался.\n${generateAccountInfo(gameInfo.account)}
      """);
    } else {
      await trySendMessage("Тебе стоит попытаться еще раз.");
    }
  }
}

class RequestAuthAction extends Action {
  RequestAuthAction(
      UserManager userManager, TaleApi taleApi, TelegramApi telegramApi)
      : super(userManager, taleApi, telegramApi);

  @override
  Future<void> performAction() async {
    await _userManager.setAuthorized(authorized: false);

    // update headers

    await taleApi.apiInfo();
    final link = await taleApi.auth();
    await trySendMessage(
      "Чтобы авторизоваться - перейди по ссылке ${apiUrl}${link.authorizationPage}",
      inlineKeyboard: InlineKeyboard([
        [InlineKeyboardButton("/confirm", "/confirm")]
      ]),
    );
  }
}

class InfoAction extends Action {
  InfoAction(UserManager userManager, TaleApi taleApi, TelegramApi telegramApi)
      : super(userManager, taleApi, telegramApi);

  @override
  Future<void> performAction() async {
    if (!await _userManager.isAuthorized()) {
      await trySendMessage(
          "Чтобы получить информацию нужно войти в аккаунт. Попробуй /auth или /start.");
      return;
    }
    final info =
        await taleApi.gameInfo(headers: await createHeaders(_userManager));
    await trySendMessage(
        "${info.account.hero.base.name} ${info.account.hero.action?.description ?? ""}.\n${generateAccountInfo(info.account)}");
  }
}

class HelpAction extends Action {
  HelpAction(UserManager userManager, TaleApi taleApi, TelegramApi telegramApi)
      : super(userManager, taleApi, telegramApi);

  @override
  Future<void> performAction() async {
    if (!await _userManager.isAuthorized()) {
      await trySendMessage(
          "Чтобы помочь нужно войти в аккаунт. Попробуй /auth или /start.");
      return;
    }

    final headers = await createHeaders(_userManager);

    final operation = await _taleApi.help(headers: headers);
    await trySendMessage("Пытаюсь помочь!");

    Timer.periodic(Duration(seconds: 1), (timer) async {
      final status = await taleApi.checkOperation(operation.statusUrl);
      if (!status.isProcessing) {
        timer.cancel();

        final gameInfo = await taleApi.gameInfo(headers: headers);
        await trySendMessage(
            "${gameInfo.account.hero.base.name} рад помощи и ${gameInfo.account.hero.action?.description ?? ""}.\n${generateAccountInfo(gameInfo.account)}");
      }
    });
  }
}

class ActionRouter {
  final UserManager _userManager;
  final TaleApi _taleApi;
  final TelegramApi _telegramApi;

  ActionRouter(this._userManager, this._taleApi, this._telegramApi);

  Action route(String action) {
    switch (action) {
      case "/start":
        return StartAction(_userManager, _taleApi, _telegramApi);
      case "/confirm":
        return ConfirmAuthAction(_userManager, _taleApi, _telegramApi);
      case "/auth":
        return RequestAuthAction(_userManager, _taleApi, _telegramApi);
      case "/info":
        return InfoAction(_userManager, _taleApi, _telegramApi);
      case "/help":
        return HelpAction(_userManager, _taleApi, _telegramApi);
      default:
        throw "Action $action not supported";
    }
  }
}

String generateAccountInfo(Account info) {
  final buffer = StringBuffer();
  buffer.writeln("⚡️ Энергия: *${info.energy}*");
  buffer.writeln(
      "❤️ Жизнь: *${info.hero.base.health} / ${info.hero.base.maxHealth}*");
  buffer.writeln(
      "⭐️ Опыт: *${info.hero.base.experience} / ${info.hero.base.experienceToLevel}*");
  buffer.writeln("💰 Денег: *${info.hero.base.money}*");
  return buffer.toString();
}

Future<Map<String, String>> createHeaders(UserManager userManager) async {
  final session = await userManager.readUserSession();
  return {
    "Referer": apiUrl,
    "X-CSRFToken": session.csrfToken,
    "Cookie": "csrftoken=${session.csrfToken}; sessionid=${session.sessionId}",
  };
}

Future processHeader(UserManager userManager, SessionInfo session,
    {bool isAuthorized = true}) async {
  print("csrftoken: ${session.csrfToken}. sessionId: ${session.sessionId}");

  await userManager.saveUserSession(session, isAuthorized: isAuthorized);
}
