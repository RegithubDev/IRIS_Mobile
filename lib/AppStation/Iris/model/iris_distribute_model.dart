class IRISDistributeRequestModel {
  String? sbuCode;
  String? date;
  String? siteId;
  String? createdBy;
  String? comments;
  String? totalMaterials;
  String? totalRecyclable;
  String? totalBags;
  String? totalGlass;
  String? totalPlastic;
  String? totalCardBoard;
  String? qualityMeasureMaterials;
  String? qualityMeasureRecyclable;
  String? qualityMeasurePlastics;
  String? qualityMeasureBags;
  String? qualityMeasureGlass;
  String? qualityMeasureCardBoard;
  String? qualityMeasureWaste;
  String? qualityMeasureIncieration;
  String? qualityMeasureAutoClave;

  IRISDistributeRequestModel(
      {this.sbuCode,
      this.date,
      this.siteId,
      this.createdBy,
      this.comments,
      this.totalMaterials,
      this.totalRecyclable,
      this.totalBags,
      this.totalGlass,
      this.totalPlastic,
      this.totalCardBoard,
      this.qualityMeasureMaterials,
      this.qualityMeasureRecyclable,
      this.qualityMeasurePlastics,
      this.qualityMeasureBags,
      this.qualityMeasureGlass,
      this.qualityMeasureCardBoard,
      this.qualityMeasureWaste,
      this.qualityMeasureIncieration,
      this.qualityMeasureAutoClave});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code":sbuCode,
      "date": date,
      "site": siteId,
      "created_by": createdBy,
      "comments": comments,
      "total_materials": totalMaterials,
      "total_recylable": totalRecyclable,
      "total_bags":totalBags,
      "total_glass": totalGlass,
      "total_plastic": totalPlastic,
      "total_cardboard": totalCardBoard,
      "quality_measure_materials": "MT",
      "quality_measure_recylable": "MT",
      "quality_measure_plastics": "MT",
      "quality_measure_bags": "MT",
      "quality_measure_glass": "MT",
      "quality_measure_cardboard": "MT",
      "quantity_measure_waste": "MT",
      "quantity_measure_incieration": "MT",
      "quantity_measure_autoclave": "MT"
    };
    return map;
  }
}

class IRISDistributeResponseModel {
  final String? status;
  final String? response;

  IRISDistributeResponseModel({this.status, this.response});

  factory IRISDistributeResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    try {
      return IRISDistributeResponseModel(
          status: json["result"]["status"] ?? "",
          response: json["result"]["message"] ?? "");
    } catch (e) {
      return IRISDistributeResponseModel(status: "", response: "");
    }
  }
}
