
import 'package:flutter/foundation.dart';

ValueNotifier<List<IwmOpenStockFormDataListResponseModel>> iwmOpenStockFormDataValueNotifier =
ValueNotifier([]);

class IwmOpenStockFormDataListResponseModel {
  final String openStockTotalWaste;
  final String openStockDlf;
  final String openStockLat;
  final String openStockIncineration;
  final String openStockAfrf;
  final String osDate;
  final String csDate;

  IwmOpenStockFormDataListResponseModel({required this.openStockTotalWaste, required this.openStockDlf, required this.openStockLat, required this.openStockIncineration, required this.openStockAfrf,required this.osDate, required this.csDate,});

}
class IwmOpenStockFormDataListRequestModel {
  String? sbuCode;
  String? siteId;

  IwmOpenStockFormDataListRequestModel(
      {this.sbuCode,this.siteId});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": "IWM",
      "site": siteId
    };
    return map;
  }
}


