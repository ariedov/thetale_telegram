import 'dart:io';

int get port => Platform.environment['PORT'] == null ? 8080 : int.parse(Platform.environment['PORT']);

String get telegramWebhook => "https://epictale-telegram.herokuapp.com/";

String get mongodbUri => "mongodb://heroku_2l2n9pbx:dsghsn4mhu58rtqan2ap8hp5af@ds247223.mlab.com:47223/heroku_2l2n9pbx";

String get token => "663762224:AAEatW0mX8svEAZdgGpMOdGJZYXKIasONNc";