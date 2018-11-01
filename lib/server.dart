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

  Future listen(RequestHandler handler) async {
    await for (HttpRequest request in _server) {
      print("Uri: ${request.requestedUri}");
      print("Url: ${request.length}");

      if (request.method == "POST" && request.contentLength > 0) {
        final decoder = json.fuse(const Utf8Codec()).decoder;
        final data = await decoder.bind(request).single;

        print("DATA: $data");
        handler(data);
      }

      final response = request.response;
      response.statusCode = 200;
      response.write(true);

      await response.close();
    }
  }
}

typedef RequestHandler = void Function(dynamic data);
