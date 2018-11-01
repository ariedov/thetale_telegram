class Response<T> {
  final T data;
  final String status;
  final String error;
  final Map<String, List<String>> errors;

  Response(this.status, {this.data, this.error, this.errors});

  bool get isError => status == "error";
}

class ThirdPartyLink {
  final String authorizationPage;

  ThirdPartyLink(this.authorizationPage);
}

class ThirdPartyStatus {
  final String url;
  final int accountId;
  final String accountName;
  final int expireAt;
  final int state;

  ThirdPartyStatus(
      this.url, this.accountId, this.accountName, this.expireAt, this.state);

  bool get isAccepted => state == 2;
}
