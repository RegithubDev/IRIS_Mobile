
import 'package:flutter/foundation.dart';

ValueNotifier<List<CollectionDataListResponseModel>> collectionDataListValueNotifier =
ValueNotifier([]);
ValueNotifier<List<CollectionDataListResponseModel>> mswCollectionDataListValueNotifier =
ValueNotifier([]);
ValueNotifier<List<CollectionDataListResponseModel>> collectionDateChecking =
ValueNotifier([]);

class CollectionDataListResponseModel {
  final String? collectionDate;
  final String? collectionQty;
  final double? qtySum;

  CollectionDataListResponseModel({required this.collectionDate,required this.collectionQty,required this.qtySum});

}
class CollectionDataListRequestModel {
  String? sbuCode;
  String? fromDate;
  String? toDate;
  String? siteId;

  CollectionDataListRequestModel(
      {this.sbuCode,this.fromDate,this.toDate,this.siteId});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": sbuCode,
      "department_code": "CNT",
      "site": siteId,
      "from_date": fromDate,
      "to_date": toDate,
      "startIndex": "0",
      "offset": "100",
    };
    return map;
  }
}


