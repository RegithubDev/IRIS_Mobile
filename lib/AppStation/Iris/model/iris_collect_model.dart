class IRISCollectRequestModel {
  String? sbuCode;
  String? date;
  String? siteId;
  String? createdBy;
  String? quantity;
  String? uom;
  String? comments;

  IRISCollectRequestModel(
      {this.sbuCode,
      this.date,
      this.siteId,
      this.createdBy,
      this.quantity,
      this.uom,
      this.comments});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": sbuCode,
      "date": date,
      "site": siteId,
      "created_by": createdBy,
      "quantity": quantity,
      "quantity_measure": "MT",
      "comments": comments
    };
    return map;
  }
}


class IRISCollectResponseModel {
  final String? status;
  final String? response;

  IRISCollectResponseModel({this.status, this.response});

  factory IRISCollectResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    try {
      return IRISCollectResponseModel(
          status: json["result"]["status"] ?? "",
          response: json["result"]["message"] ?? "");
    } catch (e) {
      return IRISCollectResponseModel(status: "", response: "");
    }
  }
}
