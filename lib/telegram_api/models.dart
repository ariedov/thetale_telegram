class Update {
  final int updateId;
  final CallbackQuery callbackQuery;
  final Message message;

  Update(this.updateId, this.callbackQuery, this.message);

  int get chatId =>
      callbackQuery != null ? callbackQuery.message.chat.id : message.chat.id;

  bool get isFromBot => callbackQuery != null
      ? callbackQuery.message.from.isBot
      : message.from.isBot;
}

class CallbackQuery {
  final String id;
  final User user;
  final Message message;
  final String inlineMessageId;
  final String chatInstance;
  final String data;
  final String gameShortName;

  CallbackQuery(this.id, this.user, this.message, this.inlineMessageId,
      this.chatInstance, this.data, this.gameShortName);
}

class Message {
  final int messageId;
  final User from;
  final Chat chat;
  final int date;
  final String text;
  final List<MessageEntity> entities;

  Message(this.messageId, this.from, this.chat, this.date, this.text,
      this.entities);
}

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String languageCode;
  final bool isBot;

  User(this.id, this.firstName, this.lastName, this.username, this.languageCode,
      {this.isBot = false});
}

class Chat {
  final int id;
  final String firstName;
  final String lastName;
  final String userName;
  final ChatType type;

  Chat(this.id, this.firstName, this.lastName, this.userName, this.type);
}

enum ChatType { private, group, supergroup, channel }

class MessageEntity {
  final int offset;
  final int length;
  final MessageEntityType type;

  MessageEntity(this.offset, this.length, this.type);
}

enum MessageEntityType {
  mention,
  hashtag,
  cashtag,
  botCommand,
  url,
  email,
  phoneNumber,
  bold,
  italic,
  code,
  pre,
  textLink,
  textMention
}

class ReplyKeyboard {
  final List<List<String>> keyboard;
  final bool resizeKeyboard = true;

  ReplyKeyboard(this.keyboard);
}

class InlineKeyboard {
  final List<List<InlineKeyboardButton>> keyboard;

  InlineKeyboard(this.keyboard);
}

class InlineKeyboardButton {
  final String text;
  final String callbackData;

  InlineKeyboardButton(this.text, this.callbackData);
}
