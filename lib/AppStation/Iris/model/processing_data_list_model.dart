
import 'package:flutter/foundation.dart';

ValueNotifier<List<ProcessingDataListResponseModel>> processingDataListValueNotifier =
ValueNotifier([]);

ValueNotifier<List<ProcessingDataListResponseModel>> processingDateChecking =
ValueNotifier([]);

class ProcessingDataListResponseModel {
  final String? processingDate;
  final String? totalIncinerationQty;
  final String? totalAutoClaveQty;
  final String? totalWeightQty;
  final double? totalWasteSum;
  final double? totalIncinerationSum;
  final double? totalAutoclaveSum;

  ProcessingDataListResponseModel({required this.processingDate,required this.totalIncinerationQty,required this.totalAutoClaveQty,required this.totalWeightQty
    ,required this.totalWasteSum,required this.totalIncinerationSum,required this.totalAutoclaveSum});

}
class ProcessingDataListRequestModel {
  String? sbuCode;
  String? fromDate;
  String? toDate;
  String? siteId;


  ProcessingDataListRequestModel(
      {this.sbuCode,this.fromDate,this.toDate});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": sbuCode,
      "department_code": "process",
      "site": siteId,
      "from_date": fromDate,
      "to_date": toDate,
      "startIndex": "0",
      "offset": "100"
    };
    return map;
  }
}


