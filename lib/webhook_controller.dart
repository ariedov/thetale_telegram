import 'dart:async';

import 'package:aqueduct/aqueduct.dart';

class WebhookController extends ResourceController {

  @Operation.post()
  Future<Response> webhookRequest() async {
    
    return Response.ok({
      "text": "Hello"
    });
  }
}
