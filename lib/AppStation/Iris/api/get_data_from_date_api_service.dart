import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:resus_test/AppStation/Iris/model/data_from_date_model.dart';

import '../../../Utility/api_Url.dart';

class GetDataFromDateAPIService extends ChangeNotifier{
  Future<void> getDataFromDateApiCall(DataFromDateRequestModel dataFromDateRequestModel, String sbu) async {
    dataFromDateRequestModel.sbuCode= sbu;
    dataFromDateValueNotifier.value.clear();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    final response = await http.post(Uri.parse(IRIS_DATA_FROM_DATE),
        body: jsonEncode(dataFromDateRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      if (response.body.isNotEmpty) {

        for (Map jsonCollection in json.decode(response.body)) {
          dataFromDateValueNotifier.value.add(
              DataFromDateResponseModel(
                   qtyTotalSum: jsonCollection["quantity"].toString(), incinerationTotalSum: jsonCollection["total_incieration"], wasteTotalSum: jsonCollection["total_waste"].toString(), autoclaveTotalSum: jsonCollection["total_autoclave"], materialTotalSum: jsonCollection["total_materials"], recyclableTotalSum:jsonCollection["total_recylable"], glassTotalSum: jsonCollection["total_glass"].toString(), bagsTotalSum:jsonCollection["total_bags"], plasticTotalSum: jsonCollection["total_plastic"], cardBoardTotalSum: jsonCollection["total_cardboard"], siteName: "", sbuCode: jsonCollection["sbu_code"],));
          MswDataFromDateResponseModel(totalSum: "", wasteTotalSum: "wasteTotalSum", incinerationTotalSum: "incinerationTotalSum", autoclaveTotalSum: "autoclaveTotalSum", materialTotalSum: "materialTotalSum", recyclableTotalSum: "recyclableTotalSum", glassTotalSum: "glassTotalSum", bagsTotalSum: "bagsTotalSum", plasticTotalSum: "plasticTotalSum", cardBoardTotalSum: "cardBoardTotalSum", siteName: "siteName", sbuCode: "sbuCode");
        }
        dataFromDateValueNotifier.notifyListeners();
      }
    }
  }
}
