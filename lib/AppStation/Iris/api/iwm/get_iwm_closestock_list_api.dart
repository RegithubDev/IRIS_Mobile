import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Utility/api_Url.dart';
import '../../model/iwm/iwm_closestock_data_model.dart';

class GetIwmCloseStockDataListAPIService extends ChangeNotifier{
  Future<void> getIwmCloseStockDataListApiCall(
      IwmCloseStockDataListRequestModel iwmCloseStockDataListRequestModel,
      String fromDate,
      String toDate,
      String? siteID) async {
    final prefs = await SharedPreferences.getInstance();
    String roles = prefs.getString('roleName').toString();
    String sites = prefs.getString("IRIS_SITE_ID").toString();
    iwmCloseStockDataListRequestModel.sbuCode = "IWM";
    iwmCloseStockDataListRequestModel.fromDate = fromDate;
    iwmCloseStockDataListRequestModel.toDate = toDate;
    iwmCloseStockDataListRequestModel.siteId =
        roles.contains("SBUHead") || sites.contains(",")
            ? siteID
            : prefs.getString('IRIS_SITE_ID') ?? "";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    final response = await http.post(Uri.parse(IRIS_DATA_MANAGEMENT),
        body: jsonEncode(iwmCloseStockDataListRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      if (response.body.isNotEmpty) {
        iwmCloseStockDataListValueNotifier.value.clear();
        for (Map jsonCollection in json.decode(response.body)) {
          iwmCloseStockDataListValueNotifier.value.add(
              IwmCloseStockDataListResponseModel(
                  closeStockTotalWaste: jsonCollection["closing_stock_total_waste"],
                  closeStockDlf: jsonCollection["closing_stock_dlf"],
                  closeStockLat: jsonCollection["closing_stock_lat"],
                  closeStockIncineration: jsonCollection["closing_stock_incineration"],
                  closeStockAfrf: jsonCollection["closing_stock_afrf"],
                  closeStockTotalWasteSum: jsonCollection["closing_stock_total_waste_sum"],
                  closeStockDlfSum: jsonCollection["closing_stock_dlf_sum"],
                  closeStockLatSum: jsonCollection["closing_stock_lat_sum"],
                  closeStockIncinerationSum: jsonCollection["closing_stock_incineration_sum"],
                  closeStockAfrfSum: jsonCollection["closing_stock_afrf_sum"],
                  date: jsonCollection["date"]));
        }
        iwmCloseStockDataListValueNotifier.notifyListeners();
      } else {
        iwmCloseStockDataListValueNotifier.value.clear();
        iwmCloseStockDataListValueNotifier.notifyListeners();
      }
    }
  }
}
