import 'package:flutter/foundation.dart';

ValueNotifier<List<IwmOpenStockDataListResponseModel>> iwmOpenStockDataListValueNotifier =
ValueNotifier([]);

ValueNotifier<List<IwmOpenStockDataListResponseModel>> iwmCheckOpenStockListNotifier =
ValueNotifier([]);

class IwmOpenStockDataListResponseModel {
  final String openStockTotalWaste;
  final String openStockDlf;
  final String openStockLat;
  final String openStockIncineration;
  final String openStockAfrf;
  final double openStockTotalWasteSum;
  final double openStockDlfSum;
  final double openStockLatSum;
  final double openStockIncinerationSum;
  final double openStockAfrfSum;
  final String date;

  IwmOpenStockDataListResponseModel({required this.openStockTotalWaste, required this.openStockDlf, required this.openStockLat, required this.openStockIncineration, required this.openStockAfrf,required this.openStockTotalWasteSum, required this.openStockDlfSum, required this.openStockLatSum, required this.openStockIncinerationSum, required this.openStockAfrfSum, required this.date});

}
class IwmOpenStockDataListRequestModel {
  String? sbuCode;
  String? fromDate;
  String? toDate;
  String? siteId;

  IwmOpenStockDataListRequestModel(
      {this.sbuCode,this.fromDate,this.toDate,this.siteId});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": sbuCode,
      "department_code": "open",
      "site": siteId,
      "from_date": fromDate,
      "to_date": toDate,
      "startIndex": "0",
      "offset": "100"
    };
    return map;
  }
}


