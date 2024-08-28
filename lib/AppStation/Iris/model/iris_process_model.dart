class IRISProcessRequestModel {
  String? sbuCode;
  String? date;
  String? siteId;
  String? createdBy;
  String? totalWaste;
  String? totalInciertion;
  String? totalAutoClave;
  String? comments;
  String? totalWasteUom;
  String? totalInciertionUom;
  String? totalAutoClaveUom;

  IRISProcessRequestModel(
      {this.sbuCode,
      this.date,
      this.siteId,
      this.createdBy,
      this.totalWaste,
      this.totalInciertion,
      this.totalAutoClave,
      this.comments,
      this.totalWasteUom,
      this.totalInciertionUom,
      this.totalAutoClaveUom});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": sbuCode,
      "date": date,
      "site": siteId,
      "created_by": createdBy,
      "total_waste": totalWaste,
      "total_incieration": totalInciertion,
      "total_autoclave": totalAutoClave,
      "comments": comments,
      "quantity_measure_waste": "MT",
      "quantity_measure_incieration": "MT",
      "quantity_measure_autoclave": "MT"
    };
    return map;
  }
}

class IRISProcessResponseModel {
  final String? status;
  final String? response;

  IRISProcessResponseModel({this.status, this.response});

  factory IRISProcessResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    try {
      return IRISProcessResponseModel(
          status: json["result"]["status"] ?? "",
          response: json["result"]["message"] ?? "");
    } catch (e) {
      return IRISProcessResponseModel(status: "", response: "");
    }
  }
}
