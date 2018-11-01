import 'dart:async';
import 'dart:convert';
import 'dart:io';

class Server {
  HttpServer _server;

  Future<HttpServer> startServer({int port = 8080}) async {
    return _server = await HttpServer.bind(
      "0.0.0.0",
      port,
    );
  }

  Stream<dynamic> listen() async* {
    await for (HttpRequest request in _server) {
      if (request.method == "POST" && request.contentLength > 0) {
        yield await request.transform(utf8.decoder).join();
      }

      final response = request.response;
      response.statusCode = 200;
      response.write(true);

      await response.close();
    }
  }
}

typedef RequestHandler = void Function(dynamic data);
