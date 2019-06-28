import 'dart:async';

import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:teledart/model.dart';
import 'package:thetale_api/thetale_api.dart';

const String apiUrl = "https://the-tale.org";

const String applicationName = "Сказка в Телеграмме";
const String applicationInfo = "Телеграм бот для игры в сказку";
const String applicationDescription = "Телеграм бот для игры в сказку";

abstract class TelegramAction {
  TelegramAction(this._chatInfo, this._taleApi, this._telegram);

  final ChatInfo _chatInfo;
  final TaleApiWrapper _taleApi;
  final TelegramWrapper _telegram;

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
  TelegramWrapper get telegram => _telegram;

  Future<Message> trySendMessage(String message,
      {ReplyMarkup replyMarkup}) async {
    try {
      return await telegram.sendMessage(_chatInfo, message, replyMarkup: replyMarkup);
    } catch (e) {
      print("Failed to send message");
    }
    return null;
  }
}

abstract class MultiUserAction extends TelegramAction {
  MultiUserAction(ChatInfo chatInfo, TaleApiWrapper taleApi, TelegramWrapper telegram)
      : super(chatInfo, taleApi, telegram);

  Future<void> performChooserAction(Map<String, String> sessionNameMap);

  Future<void> performEmptyAction();

  List<List<InlineKeyboardButton>> buildAccountListAction(
      Map<String, String> sessionNameMap, String action) {
    final List<List<InlineKeyboardButton>> buttons = [];

    for (final entry in sessionNameMap.entries) {
      buttons
          .add([InlineKeyboardButton(text: entry.value, callback_data: "$action ${entry.key}")]);
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