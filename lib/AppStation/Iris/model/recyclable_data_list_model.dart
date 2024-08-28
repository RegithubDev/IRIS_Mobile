
import 'package:flutter/foundation.dart';

ValueNotifier<List<RecyclableDataListResponseModel>> recyclableDataListValueNotifier =
ValueNotifier([]);

ValueNotifier<List<RecyclableDataListResponseModel>> recyclableDateChecking = ValueNotifier([]);

class RecyclableDataListResponseModel {
  final String? recyclableDate;
  final String? recyclableQty;
  final String? glassQty;
  final String? plasticQty;
  final String? bagsQty;
  final String? cardBoardQty;

  final String? totalMaterialSum;
  final double? totalRecyclableSum;
  final String? totalBagsSum;
  final String? totalGlassSum;
  final String? totalCardBoardSum;
  final String? totalPlasticSum;

  RecyclableDataListResponseModel({required this.recyclableDate,required this.recyclableQty,required this.glassQty,required this.plasticQty,required this.bagsQty,required this.cardBoardQty,
          required this.totalMaterialSum,required this.totalRecyclableSum,required this.totalBagsSum,required this.totalGlassSum,
         required this.totalCardBoardSum,required this.totalPlasticSum});

}
class RecyclableDataListRequestModel {
  String? sbuCode;
  String? fromDate;
  String? toDate;
  String? siteId;


  RecyclableDataListRequestModel(
      {this.sbuCode,this.fromDate,this.toDate});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code":  sbuCode,
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


