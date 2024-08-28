
import 'package:flutter/foundation.dart';

ValueNotifier<List<MswDistributeDataListResponseModel>> mswDistributeDataListValueNotifier =
ValueNotifier([]);

ValueNotifier<List<MswDistributeDataListResponseModel>> mswDistributeDateChecking =
ValueNotifier([]);

class MswDistributeDataListResponseModel {
  String date;
  String compost;
  String rdf;
  String recyclables;
  String inserts;
  String total_waste;
  num? qtySum;


  MswDistributeDataListResponseModel(
      {required this.date,
        required this.compost,
        required this.rdf,
        required this.recyclables,
        required this.inserts,
        required this.total_waste,
        this.qtySum
      });
}

class MswDistributeDataListRequestModel {
  String? sbuCode;
  String? fromDate;
  String? toDate;
  String? siteId;


  MswDistributeDataListRequestModel(
      {this.sbuCode,this.fromDate,this.toDate});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": "MSW",
      "department_code": "Dist",
      "site": siteId,
      "from_date": fromDate,
      "to_date": toDate,
      "startIndex": "0",
      "offset": "100"
    };
    return map;
  }
}


