class Response<T> {
  final T data;
  final String status;
  final String error;
  final Map<String, List<String>> errors;

  Response(this.status, {this.data, this.error, this.errors});

  bool get isError => status == "error";
}

class ApiInfo {
  final String staticContent;
  final String gameVersion;
  final int turnDelta;
  final int accountId;
  final String accountName;

  ApiInfo(this.staticContent, this.gameVersion, this.turnDelta, this.accountId,
      this.accountName);
}

class ThirdPartyLink {
  final String authorizationPage;

  ThirdPartyLink(this.authorizationPage);
}

class ThirdPartyStatus {
  final String url;
  final int accountId;
  final String accountName;
  final double expireAt;
  final int state;

  ThirdPartyStatus(
      this.url, this.accountId, this.accountName, this.expireAt, this.state);

  bool get isAccepted => state == 2;
}
