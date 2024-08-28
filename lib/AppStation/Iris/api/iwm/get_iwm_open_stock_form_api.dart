import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Utility/api_Url.dart';
import '../../model/iwm/iwm_open_stock_form_fetch_model.dart';

class GetIwmOpenStockFormDataListAPIService extends ChangeNotifier{
  Future<void> getIwmOpenStockFormDataListApiCall(
      IwmOpenStockFormDataListRequestModel iwmOpenStockFormDataListRequestModel,
      String? siteID) async {
    final prefs = await SharedPreferences.getInstance();
    iwmOpenStockFormDataListRequestModel.siteId = siteID;

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    final response = await http.post(Uri.parse(IRIS_OS_STOCK_FORM),
        body: jsonEncode(iwmOpenStockFormDataListRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      iwmOpenStockFormDataValueNotifier.value.clear();
      if (response.body.isNotEmpty) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse["Opening Stock"];

        if (jsonResponse["Opening Stock"].runtimeType != Null) {
          prefs.setString("errorResponse", "");
          iwmOpenStockFormDataValueNotifier.value.add(
              IwmOpenStockFormDataListResponseModel(
                  openStockTotalWaste: data["Opening_stock Total Waste"],
                  openStockDlf: data["Opening_stock DLF"],
                  openStockLat: data["Opening_stock LAT"],
                  openStockIncineration: data["Opening_stock Incineration"],
                  openStockAfrf: data["Opening_stock AFRF"],
                  osDate: data["OS Date"],
                  csDate: data["CS Date"]));

          prefs.setString("osDate", data["OS Date"]);
          prefs.setString("osTotalWaste", data["Opening_stock Total Waste"]);
          prefs.setString("osDLF", data["Opening_stock DLF"]);
          prefs.setString("osLAT", data["Opening_stock LAT"]);
          prefs.setString("osInc", data["Opening_stock Incineration"]);
          prefs.setString("osAfrf", data["Opening_stock AFRF"]);
        } else {
          prefs.setString("errorResponse", jsonResponse["OK"].toString());
        }
        iwmOpenStockFormDataValueNotifier.notifyListeners();
      } else {
        iwmOpenStockFormDataValueNotifier.value.clear();
        iwmOpenStockFormDataValueNotifier.notifyListeners();
      }
    }
  }
}
