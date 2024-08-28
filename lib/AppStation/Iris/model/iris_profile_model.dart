class IRISProfileRequestModel {
  String? mobileNo;
  int? userId;

  IRISProfileRequestModel(
      {this.mobileNo,this.userId});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "user_name": "user_name",
      "mobile_number": mobileNo,
      "id": userId
    };
    return map;
  }
}


class IRISProfileResponseModel {
  final String? status;
  final String? response;

  IRISProfileResponseModel({this.status, this.response});

  factory IRISProfileResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    try {
      return IRISProfileResponseModel(
          status: json["result"]["status"] ?? "",
          response: json["result"]["message"] ?? "");
    } catch (e) {
      return IRISProfileResponseModel(status: "", response: "");
    }
  }
}
