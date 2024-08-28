class PostDisposalRequestModel {
  String? sbuCode;
  String? date;
  String? siteId;
  String? createdBy;
  String? comments;
  String? disposalTotalWaste;
  String? disposalDlf;
  String? disposalLat;
  String? disposalIncineration;
  String? disposalAfrf;
  String? incinerationToAfrf;
  String? recyclingQtyToInc;
  String? recyclingQtyToAfrf;
  String? recyclingQtyTotal;

  PostDisposalRequestModel({
    this.sbuCode,
    this.date,
    this.siteId,
    this.createdBy,
    this.comments,
    this.disposalTotalWaste,
    this.disposalDlf,
    this.disposalLat,
    this.disposalIncineration,
    this.disposalAfrf,
    this.incinerationToAfrf,
    this.recyclingQtyToInc,
    this.recyclingQtyToAfrf,
    this.recyclingQtyTotal
  });

  Map<String, dynamic> toJson() {
    return {
      "sbu_code": "IWM",
      "date": date,
      "site": siteId,
      "created_by": createdBy,
      "comments": "NA",
      "disposal_total_waste": disposalTotalWaste,
      "disposal_dlf": disposalDlf,
      "disposal_lat": disposalLat,
      "disposal_incineration": disposalIncineration,
      "disposal_afrf": disposalAfrf,
      "incineration_to_afrf": incinerationToAfrf,
      "recycling_qty_inc": recyclingQtyToInc,
      "recycling_qty_afrf": recyclingQtyToAfrf,
      "recycling_qty_total": recyclingQtyTotal
    };
  }
}

class PostDisposalResponseModel {
  final String? status;
  final String? response;

  PostDisposalResponseModel({this.status, this.response});

  factory PostDisposalResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      return PostDisposalResponseModel(
        status: json["result"]["status"] ?? "",
        response: json["result"]["message"] ?? "",
      );
    } catch (e) {
      return PostDisposalResponseModel(status: "", response: "");
    }
  }
}

