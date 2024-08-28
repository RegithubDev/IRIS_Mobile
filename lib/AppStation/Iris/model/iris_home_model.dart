class IRISHomeRequestModel {
  String? emailId;

  IRISHomeRequestModel(
      {this.emailId});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "mobile" : "Yes",
      "startIndex" : "0",
      "offset" : "10",
      "email_id" : emailId
    };
    return map;
  }
}


class IRISHomeResponseModel {
  final String? status;
  final String? response;

  IRISHomeResponseModel({this.status, this.response});

  factory IRISHomeResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    try {
      return IRISHomeResponseModel(
          status: json["result"]["status"] ?? "",
          response: json["result"]["message"] ?? "");
    } catch (e) {
      return IRISHomeResponseModel(status: "", response: "");
    }
  }
}
