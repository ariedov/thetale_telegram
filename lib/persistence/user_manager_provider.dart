import 'package:epictale_telegram/persistence/mongo_user_manager.dart';
import 'package:epictale_telegram/persistence/user_manager.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UserManagerProvider {
  UserManagerProvider(this._db);

  final Db _db;

  UserManager getUserManager(int chatId) {
    return MongoUserManager(chatId, _db);
  }
}
