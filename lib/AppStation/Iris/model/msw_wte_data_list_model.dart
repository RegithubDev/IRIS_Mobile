
import 'package:flutter/foundation.dart';

ValueNotifier<List<MswWteDataListResponseModel>> mswWteDataListValueNotifier =
ValueNotifier([]);
ValueNotifier<List<MswWteDataListResponseModel>> mswWteDateChecking =
ValueNotifier([]);

class MswWteDataListResponseModel {
  String rdfReceipt;
  String rdfCombusted;
  String streamGeneration;
  String powerGeneration;
  String powerExport;
  String auxillaryConsumption;
  String powerGenerationCapacity;
  String plantLoadFactor;
  String bottomAsh;
  String flyAsh;
  String totalAsh;
  String mswWteDate;
  num? rdfReceiptSum;
  num? rdfCombustedSum;
  num? ashGeneratedSum;
  num? streamGenerationSum;
  num? powerGenerationSum;
  num? powerExportSum;
  num? bottomAshSum;
  num? flyAshSum;

  MswWteDataListResponseModel({required this.rdfReceipt, required this.rdfCombusted, required this.streamGeneration, required this.powerGeneration, required this.powerExport, required this.auxillaryConsumption, required this.powerGenerationCapacity, required this.plantLoadFactor, required this.bottomAsh, required this.flyAsh, required this.totalAsh, required this.mswWteDate, this.rdfReceiptSum, this.rdfCombustedSum, this.streamGenerationSum, this.powerGenerationSum, this.powerExportSum, this.ashGeneratedSum, this.bottomAshSum, this.flyAshSum});

}
class MswWteDataListRequestModel {
  String? sbuCode;
  String? fromDate;
  String? toDate;
  String? siteId;

  MswWteDataListRequestModel(
      {this.sbuCode,this.fromDate,this.toDate,this.siteId});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": "MSW",
      "department_code": "Wte",
      "site": siteId,
      "from_date": fromDate,
      "to_date": toDate,
      "startIndex": "0",
      "offset": "100"
    };
    return map;
  }
}


