import 'dart:async';

import 'package:epictale_telegram/telegram/telegram_wrapper.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import 'package:epictale_telegram/constants.dart';
import 'package:epictale_telegram/persistence/user_manager_provider.dart';
import 'package:epictale_telegram/room.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Application {
  Future init() async {
    final db = Db(mongodbUri);
    await db.open();

    final userProvider = UserManagerProvider(db);
    final roomFactory = RoomFactory(userProvider);
    final roomManager = RoomManager(roomFactory);

    final teledart = TeleDart(Telegram(token), Event());
    final wrapper = TelegramWrapper(teledart);

    await teledart.start();

    teledart.onCommand().listen((message) {
      final room = roomManager.getRoom(message.chat.id);
      final info = MessageInfo(chatId: message.chat.id, messageId: message.message_id);
      room.processMessage(info, wrapper, message);
      
    });

    teledart.onCallbackQuery().listen((query) {
      final room = roomManager.getRoom(query.message.chat.id);
      final info = MessageInfo(chatId: query.message.chat.id, messageId: query.message.message_id);
      room.processCallbackQuery(info, wrapper, query);
    });
  }
}
