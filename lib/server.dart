import 'dart:async';
import 'dart:io';

class Server {
  HttpServer _server;

  Future<HttpServer> startServer({int port = 8080}) async {
    _server = await HttpServer.bind(
      "0.0.0.0",
      port,
    );
    return _server;
  }

  Future listen(createResponse(String method, String path)) async {
    await for (HttpRequest request in _server) {
      final response = request.response;
      response.headers.contentType = ContentType("application", "json");

      response.write(createResponse(
        request.method,
        request.requestedUri.path,
      ));

      await response.close();
    }
  }
}
