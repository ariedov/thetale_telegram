import 'package:epictale_telegram/telegram_api/models.dart';

Update convertUpdate(dynamic json) {
  return Update(
    json["update_id"] as int,
    convertMessage(json["message"]),
  );
}

Message convertMessageAction(dynamic json) {
  final message = json["result"];
  return convertMessage(message);
}

Message convertMessage(dynamic json) {
  return Message(
    json["message_id"] as int,
    convertUser(json["from"]),
    convertChat(json["chat"]),
    json["date"] as int,
    json["text"] as String,
    convertMessageEntities(json["entities"]),
  );
}

User convertUser(dynamic json) {
  return User(
      json["id"] as int,
      json["first_name"] as String,
      json["last_name"] as String,
      json["username"] as String,
      json["languageCode"] as String,
      isBot: json["is_bot"] as bool);
}

Chat convertChat(dynamic json) {
  return Chat(
      json["id"] as int,
      json["first_name"] as String,
      json["last_name"] as String,
      json["username"] as String,
      _readChatType(json["type"] as String));
}

ChatType _readChatType(String chatType) {
  switch (chatType) {
    case "private":
      return ChatType.private;
    case "group":
      return ChatType.group;
    case "supergroup":
      return ChatType.supergroup;
    case "channel":
      return ChatType.channel;
    default:
      throw "No such chat type: $chatType";
  }
}

List<MessageEntity> convertMessageEntities(dynamic json) {
  if (json == null) {
    return [];
  }

  return (json as List).map((item) {
    return MessageEntity(
      item["offset"] as int,
      item["length"] as int,
      _readMessageEntityType(json["type"] as String),
    );
  }).toList();
}

MessageEntityType _readMessageEntityType(String name) {
  switch (name) {
    case "mention":
      return MessageEntityType.mention;
    case "hashtag":
      return MessageEntityType.hashtag;
    case "cashtag":
      return MessageEntityType.cashtag;
    case "bot_command":
      return MessageEntityType.botCommand;
    case "url":
      return MessageEntityType.url;
    case "phone_number":
      return MessageEntityType.phoneNumber;
    case "bold":
      return MessageEntityType.bold;
    case "italic":
      return MessageEntityType.italic;
    case "code":
      return MessageEntityType.code;
    case "pre":
      return MessageEntityType.pre;
    case "text_link":
      return MessageEntityType.textLink;
    case "text_mention":
      return MessageEntityType.textMention;
    default:
      throw "No such type: $name";
  }
}
