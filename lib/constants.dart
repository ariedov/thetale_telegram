import 'dart:io';

int get port => Platform.environment['PORT'] == null ? 8080 : int.parse(Platform.environment['PORT']);

String get telegramWebhook => Platform.environment['TELEGRAM_WEBHOOK'];

String get mongodbUri => Platform.environment['MONGODB_URI'];

String get token => Platform.environment['TELEGRAM_BOT_ID'];