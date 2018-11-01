import 'dart:async';

abstract class UserManager {
  Future<void> saveUserToken(String userToken);

  Future<String> readUserToken(String username);
}

class MemoryUserManager implements UserManager {

  final int chatId;
  final Map<int, String> userTokens = {};

  MemoryUserManager(this.chatId);

  @override
  Future<String> readUserToken(String username) async {
    return userTokens[username];
  }

  @override
  Future<void> saveUserToken(String userToken) async {
    userTokens[chatId] = userToken;
  }
}
