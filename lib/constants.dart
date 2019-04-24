import 'dart:io';

int get port => Platform.environment['PORT'] == null ? 8080 : int.parse(Platform.environment['PORT']);

String get telegramWebhook => Platform.environment['WEBHOOK'] == null ? "https://epictale-telegram.herokuapp.com/" : Platform.environment['WEBHOOK'];

String get mongodbUri => Platform.environment['MONGO'] == null ? "mongodb://heroku_2l2n9pbx:dsghsn4mhu58rtqan2ap8hp5af@ds247223.mlab.com:47223/heroku_2l2n9pbx" : Platform.environment['MONGO'];

String get token => "663762224:AAEatW0mX8svEAZdgGpMOdGJZYXKIasONNc";