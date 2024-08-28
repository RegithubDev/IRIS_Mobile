import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:resus_test/AppStation/Iris/model/iwm/iwm_openstock_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Utility/api_Url.dart';

class GetIwmOpenStockDataListAPIService extends ChangeNotifier{
  Future<void> getIwmOpenStockDataListApiCall(
      IwmOpenStockDataListRequestModel iwmOpenStockDataListRequestModel,
      String fromDate,
      String toDate,
      String? siteID) async {
    final prefs = await SharedPreferences.getInstance();
    String roles = prefs.getString('roleName').toString();
    String sites = prefs.getString("IRIS_SITE_ID").toString();
    iwmOpenStockDataListRequestModel.sbuCode = "IWM";
    iwmOpenStockDataListRequestModel.fromDate = fromDate;
    iwmOpenStockDataListRequestModel.toDate = toDate;
    iwmOpenStockDataListRequestModel.siteId =
        roles.contains("SBUHead") || sites.contains(",")
            ? siteID
            : prefs.getString('IRIS_SITE_ID') ?? "";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    final response = await http.post(Uri.parse(IRIS_DATA_MANAGEMENT),
        body: jsonEncode(iwmOpenStockDataListRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      if (response.body.isNotEmpty) {
        iwmOpenStockDataListValueNotifier.value.clear();
        for (Map jsonCollection in json.decode(response.body)) {
          iwmOpenStockDataListValueNotifier.value.add(
              IwmOpenStockDataListResponseModel(
                  openStockTotalWaste:
                      jsonCollection["opening_stock_total_waste"],
                  openStockDlf: jsonCollection["opening_stock_dlf"],
                  openStockLat: jsonCollection["opening_stock_lat"],
                  openStockIncineration:
                      jsonCollection["opening_stock_incineration"],
                  openStockAfrf: jsonCollection["opening_stock_afrf"],
                  openStockTotalWasteSum:
                      jsonCollection["opening_stock_total_waste_sum"],
                  openStockDlfSum: jsonCollection["opening_stock_dlf_sum"],
                  openStockLatSum: jsonCollection["opening_stock_lat_sum"],
                  openStockIncinerationSum:
                      jsonCollection["opening_stock_incineration_sum"],
                  openStockAfrfSum:
                      jsonCollection["opening_stock_afrf_sum"],
                  date: jsonCollection["date"]));

          prefs.setString("osDate", iwmOpenStockDataListValueNotifier.value.last.date);
          prefs.setString("osDLF", iwmOpenStockDataListValueNotifier.value.last.openStockDlf);
          prefs.setString("osLAT", iwmOpenStockDataListValueNotifier.value.last.openStockLat);
          prefs.setString("osInc", iwmOpenStockDataListValueNotifier.value.last.openStockIncineration);
          prefs.setString("osAfrf", iwmOpenStockDataListValueNotifier.value.last.openStockAfrf);
          prefs.setString("osTotalWaste", iwmOpenStockDataListValueNotifier.value.last.openStockTotalWaste);


        }
        iwmOpenStockDataListValueNotifier.notifyListeners();
      } else {
        iwmOpenStockDataListValueNotifier.value.clear();
        iwmOpenStockDataListValueNotifier.notifyListeners();
      }
    }
  }
}
