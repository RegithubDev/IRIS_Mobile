
import 'package:flutter/foundation.dart';

ValueNotifier<List<DataFromDateResponseModel>> dataFromDateValueNotifier =
ValueNotifier([]);
ValueNotifier<List<MswDataFromDateResponseModel>> mswDataFromDateValueNotifier =
ValueNotifier([]);

class DataFromDateResponseModel {
  final String? qtyTotalSum;
  final String? wasteTotalSum;
  final String? incinerationTotalSum;
  final String? autoclaveTotalSum;
  final String? materialTotalSum;
  final String? recyclableTotalSum;
  final String? glassTotalSum;
  final String? bagsTotalSum;
  final String? plasticTotalSum;
  final String? cardBoardTotalSum;
  final String? siteName;
  final String? sbuCode;

  DataFromDateResponseModel({required this.qtyTotalSum,required this.wasteTotalSum,required this.incinerationTotalSum,
         required this.autoclaveTotalSum,required this.materialTotalSum,required this.recyclableTotalSum,required this.glassTotalSum,
      required this.bagsTotalSum,required this.plasticTotalSum,required this.cardBoardTotalSum,required this.siteName, required this.sbuCode});

}

class MswDataFromDateResponseModel {
  final String? totalSum;
  final String? wasteTotalSum;
  final String? incinerationTotalSum;
  final String? autoclaveTotalSum;
  final String? materialTotalSum;
  final String? recyclableTotalSum;
  final String? glassTotalSum;
  final String? bagsTotalSum;
  final String? plasticTotalSum;
  final String? cardBoardTotalSum;
  final String? siteName;
  final String? sbuCode;

  MswDataFromDateResponseModel({required this.totalSum,required this.wasteTotalSum,required this.incinerationTotalSum,
    required this.autoclaveTotalSum,required this.materialTotalSum,required this.recyclableTotalSum,required this.glassTotalSum,
    required this.bagsTotalSum,required this.plasticTotalSum,required this.cardBoardTotalSum,required this.siteName, required this.sbuCode});

}

class DataFromDateRequestModel {
  String? sbuCode;
  String? mDate;


  DataFromDateRequestModel(
      {this.sbuCode,this.mDate});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": sbuCode,
      "date": mDate
    };
    return map;
  }
}


