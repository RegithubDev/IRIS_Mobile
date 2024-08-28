class PostReceiptRequestModel {
  String? sbuCode;
  String? date;
  String? siteId;
  String? createdBy;
  String? comments;
  String? receiptTotalWaste;
  String? receiptDlf;
  String? receiptLat;
  String? receiptIncineration;
  String? receiptAfrf;
  String? incinerationToAfrf;

  PostReceiptRequestModel({
    this.sbuCode,
    this.date,
    this.siteId,
    this.createdBy,
    this.comments,
    this.receiptTotalWaste,
    this.receiptDlf,
    this.receiptLat,
    this.receiptIncineration,
    this.receiptAfrf,
    this.incinerationToAfrf,
  });

  Map<String, dynamic> toJson() {
    return {
      "sbu_code": "IWM",
      "date": date,
      "site": siteId,
      "created_by": createdBy,
      "comments": "NA",
      "receipt_total_waste": receiptTotalWaste,
      "receipt_dlf": receiptDlf,
      "receipt_lat": receiptLat,
      "receipt_incineration": receiptIncineration,
      "receipt_afrf": receiptAfrf,
      "incineration_to_afrf": incinerationToAfrf,
    };
  }
}

class PostReceiptResponseModel {
  final String? status;
  final String? response;

  PostReceiptResponseModel({this.status, this.response});

  factory PostReceiptResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      return PostReceiptResponseModel(
        status: json["result"]["status"] ?? "",
        response: json["result"]["message"] ?? "",
      );
    } catch (e) {
      return PostReceiptResponseModel(status: "", response: "");
    }
  }
}

