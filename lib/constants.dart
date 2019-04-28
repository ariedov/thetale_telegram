import 'dart:io';

int get port => Platform.environment['PORT'] == null ? 8080 : int.parse(Platform.environment['PORT']);

String get telegramWebhook => Platform.environment['WEBHOOK'] == null ? "https://epictale-telegram.herokuapp.com/" : Platform.environment['WEBHOOK'];

String get mongodbUri => Platform.environment['MONGO'] == null ? "mongodb://mongo:27017" : Platform.environment['MONGO'];

String get token => "663762224:AAEatW0mX8svEAZdgGpMOdGJZYXKIasONNc";