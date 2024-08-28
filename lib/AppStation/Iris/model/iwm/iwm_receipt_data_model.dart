import 'package:flutter/foundation.dart';

ValueNotifier<List<IwmReceiptDataListResponseModel>> iwmReceiptDataListNotifier =
ValueNotifier([]);

ValueNotifier<List<IwmReceiptDataListResponseModel>> iwmCheckReceiptListNotifier =
ValueNotifier([]);

class IwmReceiptDataListResponseModel {
  final String receiptTotalWaste;
  final String receiptDlf;
  final String receiptLat;
  final String receiptIncineration;
  final String receiptAfrf;
  final String receiptIncinerationToAfrf;
  final double receiptTotalWasteSum;
  final double receiptDlfSum;
  final double receiptLatSum;
  final double receiptIncinerationSum;
  final double receiptAfrfSum;
  final double receiptIncinerationToAfrfSum;
  final String date;


  IwmReceiptDataListResponseModel({required this.receiptTotalWaste, required this.receiptDlf, required this.receiptLat, required this.receiptAfrf, required this.receiptIncineration,required this.receiptTotalWasteSum, required this.receiptAfrfSum, required this.receiptDlfSum, required this.receiptIncinerationSum, required this.receiptLatSum, required this.date, required this.receiptIncinerationToAfrf, required this.receiptIncinerationToAfrfSum});

}
class IwmReceiptDataListRequestModel {
  String? sbuCode;
  String? fromDate;
  String? toDate;
  String? siteId;

  IwmReceiptDataListRequestModel(
      {this.sbuCode,this.fromDate,this.toDate,this.siteId});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": sbuCode,
      "department_code": "receipt",
      "site": siteId,
      "from_date": fromDate,
      "to_date": toDate,
      "startIndex": "0",
      "offset": "100"
    };
    return map;
  }
}


