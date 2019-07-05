import 'dart:async';

import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';

class TelegramWrapper {
  TelegramWrapper(this.teleDart);

  final TeleDart teleDart;

  Future<Message> sendMessage(int chatId, String text,
      {ReplyMarkup replyMarkup}) {
    return teleDart.telegram.sendMessage(chatId, text,
        reply_markup: replyMarkup, parse_mode: "Markdown");
  }

  Future<Message> updateMessageReplyMarkup(
      MessageInfo messageInfo, InlineKeyboardMarkup replyMarkup) {
    return teleDart.telegram.editMessageReplyMarkup(
        chat_id: messageInfo.chatId,
        message_id: messageInfo.messageId,
        reply_markup: replyMarkup);
  }

  Future<Message> updateMessageText(
      MessageInfo messageInfo, String messageText) {
    return teleDart.telegram.editMessageText(messageText,
        chat_id: messageInfo.chatId, message_id: messageInfo.messageId);
  }
}

class MessageInfo {
  MessageInfo({this.chatId, this.messageId});

  final int chatId;

  final int messageId;
}
