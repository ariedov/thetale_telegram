import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/tale_api/models.dart';
import 'package:epictale_telegram/tale_api/tale_api.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';

abstract class Action {
  Action(this._userManager, this._taleApi, this._telegramApi);

  final UserManager _userManager;
  final TaleApi _taleApi;
  final TelegramApi _telegramApi;

  Future<void> apply({String account}) async {
    try {
      await _performAction(account: account);
    } catch (e) {
      if (e is String) {
        await trySendMessage(e);
      }
      print(e);
      await trySendMessage(
          "Возникла ошибка. Попробуй переподключить аккаунт через /auth");
    }
  }

  Future<void> _performAction({String account});

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
  Future<void> _performAction({String account}) async {
    await trySendMessage("Привет, хранитель!");

    await _userManager.clearAll();
    final info = await taleApi.apiInfo();
    await _userManager.addUserSession(info.sessionInfo);

    await trySendMessage("""
        Версия игры ${info.data.gameVersion}. Сейчас попробую тебя авторизовать.
        /start - начать все по новой
        /auth - снова авторизироваться
        /confirm - подтвердить авторизацию после того как дал доступ боту (мне)

        /add - добавить персонажа
        /remove - удалить персонажа

        /help - помочь своему герою
        /info - получить информацию о герое
        """);

    final link = await taleApi.auth(headers: await createHeaders(_userManager));
    await trySendMessage(
      "Чтобы авторизоваться - перейди по ссылке ${apiUrl}${link.authorizationPage}",
      inlineKeyboard: InlineKeyboard([
        [
          InlineKeyboardButton(
              "/confirm", "/confirm ${info.sessionInfo.sessionId}")
        ]
      ]),
    );
  }
}

class ConfirmAuthAction extends Action {
  ConfirmAuthAction(
      UserManager userManager, TaleApi taleApi, TelegramApi telegramApi)
      : super(userManager, taleApi, telegramApi);

  @override
  Future<void> _performAction({String account}) async {
    final sessions = await _userManager.readUserSession();
    final session = sessions.firstWhere((info) => info.sessionId == account);

    final status = await taleApi.authStatus(
        headers: await createHeadersFromSession(session));

    if (status.data.isAccepted) {
      await _userManager.saveUserSession(status.sessionInfo);
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
  Future<void> _performAction({String account}) async {
    await _userManager.clearAll();
    final info = await taleApi.apiInfo();

    await _userManager.addUserSession(info.sessionInfo);

    final link = await taleApi.auth(headers: await createHeaders(_userManager));
    await trySendMessage(
      "Чтобы авторизоваться - перейди по ссылке ${apiUrl}${link.authorizationPage}",
      inlineKeyboard: InlineKeyboard([
        [
          InlineKeyboardButton(
              "/confirm", "/confirm ${info.sessionInfo.sessionId}")
        ]
      ]),
    );
  }
}

class InfoAction extends Action {
  InfoAction(UserManager userManager, TaleApi taleApi, TelegramApi telegramApi)
      : super(userManager, taleApi, telegramApi);

  @override
  Future<void> _performAction({String account}) async {
    final sessions = await _userManager.readUserSession();

    if (sessions.isEmpty) {
      await trySendMessage(
          "Чтобы получить информацию нужно войти в аккаунт. Попробуй /auth или /start.");
      return;
    }

    final accountSession = sessions.firstWhere(
        (session) => session.sessionId == account,
        orElse: () => null);
    if (accountSession == null && sessions.length > 1) {
      await trySendMessage("Выбери о ком ты хочешь узнать.",
          inlineKeyboard: InlineKeyboard(
              await buildAccountListAction(sessions, taleApi, "/info")));
      return;
    }

    Map<String, String> headers;
    if (accountSession != null) {
      headers = await createHeadersFromSession(accountSession);
    } else {
      headers = await createHeaders(_userManager);
    }

    final info = await taleApi.gameInfo(headers: headers);
    await trySendMessage(
        "${info.account.hero.base.name} ${info.account.hero.action?.description ?? ""}.\n${generateAccountInfo(info.account)}");
  }
}

class HelpAction extends Action {
  HelpAction(UserManager userManager, TaleApi taleApi, TelegramApi telegramApi)
      : super(userManager, taleApi, telegramApi);

  @override
  Future<void> _performAction({String account}) async {
    final sessions = await _userManager.readUserSession();

    if (sessions.isEmpty) {
      await trySendMessage(
          "Чтобы помочь нужно войти в аккаунт. Попробуй /auth или /start.");
      return;
    }

    final accountSession = sessions.firstWhere(
        (session) => session.sessionId == account,
        orElse: () => null);
    if (accountSession == null && sessions.length > 1) {
      await trySendMessage("Выбери кому ты хочешь помочь.",
          inlineKeyboard: InlineKeyboard(
              await buildAccountListAction(sessions, taleApi, "/help")));
      return;
    }

    Map<String, String> headers;
    if (accountSession != null) {
      headers = await createHeadersFromSession(accountSession);
    } else {
      headers = await createHeaders(_userManager);
    }

    final operation = await _taleApi.help(headers: headers);
    await trySendMessage("Пытаюсь помочь!");

    Timer.periodic(Duration(seconds: 1), (timer) async {
      final status =
          await taleApi.checkOperation(operation.statusUrl, headers: headers);
      if (!status.isProcessing) {
        timer.cancel();

        final gameInfo = await taleApi.gameInfo(headers: headers);
        await trySendMessage(
            "${gameInfo.account.hero.base.name} рад помощи и ${gameInfo.account.hero.action?.description ?? ""}.\n${generateAccountInfo(gameInfo.account)}");
      }
    });
  }
}

class AddAccountAction extends Action {
  AddAccountAction(
      UserManager userManager, TaleApi taleApi, TelegramApi telegramApi)
      : super(userManager, taleApi, telegramApi);

  @override
  Future<void> _performAction({String account}) async {
    final info = await taleApi.apiInfo();
    await _userManager.addUserSession(info.sessionInfo);

    final link = await taleApi.auth(
        headers: await createHeadersFromSession(info.sessionInfo));
    await trySendMessage(
      "Чтобы добавить аккаунт - перейди по ссылке ${apiUrl}${link.authorizationPage}",
      inlineKeyboard: InlineKeyboard([
        [
          InlineKeyboardButton(
              "/confirm", "/confirm ${info.sessionInfo.sessionId}")
        ]
      ]),
    );
  }
}

class RemoveAccountAction extends Action {
  RemoveAccountAction(
      UserManager userManager, TaleApi taleApi, TelegramApi telegramApi)
      : super(userManager, taleApi, telegramApi);

  @override
  Future<void> _performAction({String account}) async {
    final sessions = await _userManager.readUserSession();

    if (account == null) {
      await trySendMessage(
        "Выбери героя чтобы удалить.",
        inlineKeyboard: InlineKeyboard(await buildAccountListAction(
            sessions, taleApi, "/remove",
            allowUnauthorized: true)),
      );
    } else {
      final session = sessions.firstWhere((item) => item.sessionId == account,
          orElse: () => null);
      await _userManager.clearSession(session);

      await trySendMessage(
        "Сессия ${account} удалена.",
      );
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
  final sessions = await userManager.readUserSession();
  final session = sessions[0];
  return createHeadersFromSession(session);
}

Future<List<List<InlineKeyboardButton>>> buildAccountListAction(
    List<SessionInfo> sessions, TaleApi taleApi, String action,
    {bool allowUnauthorized = false}) async {
  final List<List<InlineKeyboardButton>> buttons = [];
  for (final session in sessions) {
    final info = await taleApi.gameInfo(
        headers: await createHeadersFromSession(session));
    if (info.account != null || allowUnauthorized) {
      buttons.add([
        InlineKeyboardButton(
            info.account?.hero?.base?.name ?? session.sessionId,
            "$action ${session.sessionId}")
      ]);
    }
  }
  return buttons;
}

Future<Map<String, String>> createHeadersFromSession(
    SessionInfo session) async {
  return {
    "Referer": apiUrl,
    "X-CSRFToken": session.csrfToken,
    "Cookie": "csrftoken=${session.csrfToken}; sessionid=${session.sessionId}",
  };
}
