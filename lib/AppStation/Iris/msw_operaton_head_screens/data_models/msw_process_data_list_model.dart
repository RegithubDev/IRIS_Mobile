import 'package:flutter/foundation.dart';

ValueNotifier<List<MswProcessDataListResponseModel>>
    mswProcessingDataListValueNotifier = ValueNotifier([]);

ValueNotifier<List<MswProcessDataListResponseModel>> mswProcessingDateChecking =
    ValueNotifier([]);

class MswProcessDataListResponseModel {
  String date;
  String total_compost;
  String total_rdf;
  String total_recylables;
  String total_inerts;
  String total_waste;
  double? qtySum;

  MswProcessDataListResponseModel(
      {required this.date,
      required this.total_compost,
      required this.total_rdf,
      required this.total_recylables,
      required this.total_inerts,
      required this.total_waste,
      this.qtySum});
}

class MswProcessingDataListRequestModel {
  String? sbuCode;
  String? fromDate;
  String? toDate;
  String? siteId;

  MswProcessingDataListRequestModel({this.sbuCode, this.fromDate, this.toDate});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": "MSW",
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
