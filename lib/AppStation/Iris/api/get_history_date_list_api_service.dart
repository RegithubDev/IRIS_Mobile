import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:resus_test/AppStation/Iris/model/history_date_list_model.dart';

import '../../../Utility/api_Url.dart';

class GetHistoryDateListAPIService extends ChangeNotifier{
  Future<void> getHistoryDateListApiCall(
      HistoryDateListRequestModel historyDateListRequestModel, String sbu) async {
    historyDateListRequestModel.sbuCode = sbu;
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    final response = await http.post(Uri.parse(IRIS_DATE_LIST),
        body: jsonEncode(historyDateListRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      historyDateListValueNotifier.value.clear();
      if (response.body.isNotEmpty) {
        for (Map jsonCollection in json.decode(response.body)) {
          historyDateListValueNotifier.value.add(HistoryDateListResponseModel(
              collectionDate: jsonCollection["date"],
              totalMaterial: jsonCollection["total_materials"],
              totalRecyclable: jsonCollection["total_recyclable"],
              totalWaste: jsonCollection["total_waste"],
              quantity: jsonCollection["quantity"],
              totalIncineration: jsonCollection["total_incineration"],
              totalAutoclave: jsonCollection["total_autoclave"],
              totalGlass: jsonCollection["total_glass"],
              totalPlastic: jsonCollection["total_plastic"],
              totalBags: jsonCollection["total_bags"],
              totalCardboard: jsonCollection["total_cardboard"],
              siteName: jsonCollection["site_name"],
              sbuCode: jsonCollection["sbu_code"]
          ));
        }
        historyDateListValueNotifier.notifyListeners();
      }else{
        historyDateListValueNotifier.value.clear();
        historyDateListValueNotifier.notifyListeners();
      }
    }
  }
}
