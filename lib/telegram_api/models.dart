class Update {
  Update(this.updateId, this.callbackQuery, this.message);

  final int updateId;
  final CallbackQuery callbackQuery;
  final Message message;


  int get chatId =>
      callbackQuery != null ? callbackQuery.message.chat.id : message.chat.id;

  bool get isFromBot => callbackQuery != null
      ? callbackQuery.message.from.isBot
      : message.from.isBot;
}

class CallbackQuery {
  CallbackQuery(this.id, this.user, this.message, this.inlineMessageId,
      this.chatInstance, this.data, this.gameShortName);

  final String id;
  final User user;
  final Message message;
  final String inlineMessageId;
  final String chatInstance;
  final String data;
  final String gameShortName;
}

class Message {
  Message(this.messageId, this.from, this.chat, this.date, this.text,
      this.entities);

  final int messageId;
  final User from;
  final Chat chat;
  final int date;
  final String text;
  final List<MessageEntity> entities;
}

class User {
  User(this.id, this.firstName, this.lastName, this.username, this.languageCode,
      {this.isBot = false});
      
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String languageCode;
  final bool isBot;
}

class Chat {
  Chat(this.id, this.firstName, this.lastName, this.userName, this.type);

  final int id;
  final String firstName;
  final String lastName;
  final String userName;
  final ChatType type;
}

enum ChatType { private, group, supergroup, channel }

class MessageEntity {
  MessageEntity(this.offset, this.length, this.type);

  final int offset;
  final int length;
  final MessageEntityType type;
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
  ReplyKeyboard(this.keyboard);

  final List<List<String>> keyboard;
  final bool resizeKeyboard = true;
}

class InlineKeyboard {
  InlineKeyboard(this.keyboard);

  final List<List<InlineKeyboardButton>> keyboard;
}

class InlineKeyboardButton {
  InlineKeyboardButton(this.text, this.callbackData);

  final String text;
  final String callbackData;
}
