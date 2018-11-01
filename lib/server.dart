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

  Future listen(createResponse(String method, String path)) async {
    await for (HttpRequest request in _server) {
      print("Uri: ${request.requestedUri}");
    
      final decoder = json.fuse(const Utf8Codec()).decoder;
      final data = await decoder.bind(request).single;

      print("DATA: $data");
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
