import 'package:flutter/foundation.dart';

ValueNotifier<List<IwmCloseStockDataListResponseModel>> iwmCloseStockDataListValueNotifier =
ValueNotifier([]);

ValueNotifier<List<IwmCloseStockDataListResponseModel>> iwmCheckCloseStockDataListValueNotifier =
ValueNotifier([]);

class IwmCloseStockDataListResponseModel {
  final String closeStockTotalWaste;
  final String closeStockDlf;
  final String closeStockLat;
  final String closeStockIncineration;
  final String closeStockAfrf;
  final double closeStockTotalWasteSum;
  final double closeStockDlfSum;
  final double closeStockLatSum;
  final double closeStockIncinerationSum;
  final double closeStockAfrfSum;
  final String date;

  IwmCloseStockDataListResponseModel({required this.closeStockTotalWaste, required this.closeStockDlf, required this.closeStockLat, required this.closeStockIncineration, required this.closeStockAfrf,required this.closeStockTotalWasteSum, required this.closeStockDlfSum, required this.closeStockLatSum, required this.closeStockIncinerationSum, required this.closeStockAfrfSum, required this.date});

}
class IwmCloseStockDataListRequestModel {
  String? sbuCode;
  String? fromDate;
  String? toDate;
  String? siteId;

  IwmCloseStockDataListRequestModel(
      {this.sbuCode,this.fromDate,this.toDate,this.siteId});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": sbuCode,
      "department_code": "close",
      "site": siteId,
      "from_date": fromDate,
      "to_date": toDate,
      "startIndex": "0",
      "offset": "100"
    };
    return map;
  }
}


