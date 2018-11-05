# epictale_telegram

You can reach the bot here: [@EpicTaleBot](https://t.me/EpicTaleBot)

This application is a telegram bot written in `dart` for [https://the-tale.org/](https://the-tale.org/).
The only dependencies are the `http` for communicating with telegram and `mongo_dart` for persistence.

The application does store the users `csrf` token and `sessionid` for recovering the session after server restart.

## Running the Application Locally

Run the `bin/main.dart` file.

```bash
./dart-sdk/bin/dart bin/main.dart
```

## Running Application Tests

To run tests execute:

```bash
pub run test test/
```