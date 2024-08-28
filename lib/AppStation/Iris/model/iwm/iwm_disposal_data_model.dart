import 'package:flutter/foundation.dart';

ValueNotifier<List<IwmDisposalDataListResponseModel>> iwmDisposalDataListNotifier =
ValueNotifier([]);

ValueNotifier<List<IwmDisposalDataListResponseModel>> iwmCheckDisposalDataListNotifier =
ValueNotifier([]);

class IwmDisposalDataListResponseModel {
  final String disposalTotalWaste;
  final String disposalDlf;
  final String disposalLat;
  final String disposalIncineration;
  final String disposalAfrf;
  final String disposalRecycQtyInc;
  final String disposalRecycQtyAfrf;
  final String disposalRecycQtyTotal;
  final String disposalIncinerationToAfrf;
  final double disposalTotalWasteSum;
  final double disposalDlfSum;
  final double disposalLatSum;
  final double disposalIncinerationSum;
  final double disposalAfrfSum;
  final double disposalIncinerationToAfrfSum;
  final double disposalRecycQtyIncSum;
  final double disposalRecycQtyAfrfSum;
  final double disposalRecycQtyTotalSum;
  final String date;


  IwmDisposalDataListResponseModel({required this.disposalTotalWaste, required this.disposalDlf,required this.disposalLat,required this.disposalIncineration,required this.disposalAfrf,required this.disposalIncinerationToAfrf,required this.disposalRecycQtyTotal,required this.disposalRecycQtyAfrf,required this.disposalRecycQtyInc,required this.disposalTotalWasteSum,required this.disposalDlfSum,required this.disposalLatSum, required this.disposalAfrfSum,required this.disposalIncinerationSum,required this.disposalIncinerationToAfrfSum,required this.disposalRecycQtyTotalSum,required this.disposalRecycQtyIncSum, required this.disposalRecycQtyAfrfSum, required this.date});
}
class IwmDisposalDataListRequestModel {
  String? sbuCode;
  String? fromDate;
  String? toDate;
  String? siteId;

  IwmDisposalDataListRequestModel(
      {this.sbuCode,this.fromDate,this.toDate,this.siteId});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": sbuCode,
      "department_code": "Disp",
      "site": siteId,
      "from_date": fromDate,
      "to_date": toDate,
      "startIndex": "0",
      "offset": "100"
    };
    return map;
  }
}


