
import 'package:flutter/foundation.dart';

ValueNotifier<List<HistoryDateListResponseModel>> historyDateListValueNotifier =
ValueNotifier([]);

class HistoryDateListResponseModel {
  final String? collectionDate;
  final String? totalMaterial;
  final String? totalRecyclable;
  final String? totalWaste;
  final String? quantity;
  final String? totalIncineration;
  final String? totalAutoclave;
  final String? totalGlass;
  final String? totalPlastic;
  final String? totalBags;
  final String? totalCardboard;
  final String? siteName;
  final String? sbuCode;

  HistoryDateListResponseModel({required this.collectionDate, required this.totalMaterial, required this.totalRecyclable, required this.totalWaste, required this.quantity, required this.totalIncineration, required this.totalAutoclave, required this.totalGlass, required this.totalPlastic, required this.totalBags, required this.totalCardboard, required this.siteName, required this.sbuCode});

}
class HistoryDateListRequestModel {
  String? sbuCode;
  String? fromDate;
  String? toDate;

  HistoryDateListRequestModel(
      {this.sbuCode,this.fromDate,this.toDate});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": sbuCode,
      "from_date": fromDate,
      "to_date": toDate
    };
    return map;
  }
}


