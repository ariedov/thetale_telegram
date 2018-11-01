import 'dart:async';

abstract class UserManager {
  Future<void> saveUserToken(String username, String userToken);

  Future<String> readUserToken(String username);
}

class MemoryUserManager implements UserManager {
  
  final Map<String, String> userTokens = {};

  @override
  Future<String> readUserToken(String username) async {
    return userTokens[username];
  }

  @override
  Future<void> saveUserToken(String username, String userToken) async {
    userTokens[username] = userToken;
  }
}
