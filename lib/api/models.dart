class Update {
  final int updateId;
  final Message message;

  Update(this.updateId, this.message);
}

class Message {
  final int messageId;
  final User from;
  final Chat chat;
  final int date;
  final String text;
  final List<MessageEntity> entities;

  Message(this.messageId, this.from, this.chat, this.date, this.text, this.entities);
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
}

enum MessageEntityType {
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
