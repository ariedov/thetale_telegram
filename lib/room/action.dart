import 'dart:async';

import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:epictale_telegram/telegram_api/models.dart';
import 'package:epictale_telegram/telegram_api/telegram_api.dart';
import 'package:thetale_api/thetale_api.dart';

const String apiUrl = "https://the-tale.org";

const String applicationName = "Сказка в Телеграмме";
const String applicationInfo = "Телеграм бот для игры в сказку";
const String applicationDescription = "Телеграм бот для игры в сказку";

abstract class TelegramAction {
  TelegramAction(this._taleApi, this._telegramApi);

  final TaleApiWrapper _taleApi;
  final TelegramApi _telegramApi;

  Future<void> apply({String account}) async {
    try {
      await performAction(account: account);
    } catch (e) {
      if (e is String) {
        await trySendMessage(e);
      }
      print(e);
      await trySendMessage(
          "Возникла ошибка. Попробуй переподключить аккаунт через /auth");
    }
  }

  Future<void> performAction({String account});

  TaleApiWrapper get taleApi => _taleApi;
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

abstract class MultiUserAction extends TelegramAction {
  MultiUserAction(TaleApiWrapper taleApi, TelegramApi telegramApi)
      : super(taleApi, telegramApi);

  Future<void> performChooserAction(Map<String, String> nameSessionMap);

  List<List<InlineKeyboardButton>> buildAccountListAction(
      Map<String, String> nameSessionMap, String action) {
    final List<List<InlineKeyboardButton>> buttons = [];

    for (final key in nameSessionMap.keys) {
      buttons
          .add([InlineKeyboardButton(key, "$action ${nameSessionMap[key]}")]);
    }
    return buttons;
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