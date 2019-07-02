import 'dart:async';

import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';

class TelegramWrapper {
  TelegramWrapper(this.teleDart);

  final TeleDart teleDart;

  Future<Message> sendMessage(ChatInfo chatInfo, String text, {ReplyMarkup replyMarkup}) {
    return teleDart.telegram.sendMessage(chatInfo.chatId, text, reply_markup: replyMarkup, parse_mode: "Markup");
  }
}

class ChatInfo {
  ChatInfo(this.chatId);

  final int chatId;
}