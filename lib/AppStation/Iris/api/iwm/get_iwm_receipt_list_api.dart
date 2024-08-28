import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Utility/api_Url.dart';
import '../../model/iwm/iwm_receipt_data_model.dart';

class GetIwmReceiptDataListAPIService extends ChangeNotifier{
  Future<void> getIwmReceiptDataListApiCall(
      IwmReceiptDataListRequestModel iwmReceiptDataListRequestModel,
      String fromDate,
      String toDate,
      String? siteID) async {
    final prefs = await SharedPreferences.getInstance();
    String roles = prefs.getString('roleName').toString();
    String sites = prefs.getString("IRIS_SITE_ID").toString();
    iwmReceiptDataListRequestModel.sbuCode = "IWM";
    iwmReceiptDataListRequestModel.fromDate = fromDate;
    iwmReceiptDataListRequestModel.toDate = toDate;
    iwmReceiptDataListRequestModel.siteId =
    roles.contains("SBUHead") || sites.contains(",")
        ? siteID
        : prefs.getString('IRIS_SITE_ID') ?? "";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    final response = await http.post(Uri.parse(IRIS_DATA_MANAGEMENT),
        body: jsonEncode(iwmReceiptDataListRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      if (response.body.isNotEmpty) {
        iwmReceiptDataListNotifier.value.clear();
        for (Map jsonCollection in json.decode(response.body)) {
          iwmReceiptDataListNotifier.value.add(
              IwmReceiptDataListResponseModel(receiptTotalWaste: jsonCollection['receipt_total_waste'], receiptDlf: jsonCollection['receipt_dlf'], receiptLat: jsonCollection['receipt_lat'], receiptAfrf: jsonCollection['receipt_afrf'], receiptIncineration: jsonCollection['receipt_incineration'], receiptTotalWasteSum: jsonCollection['receipt_total_waste_sum'], receiptAfrfSum: jsonCollection['receipt_afrf_sum'], receiptDlfSum: jsonCollection['receipt_dlf_sum'], receiptIncinerationSum: jsonCollection['receipt_incineration_sum'], receiptLatSum: jsonCollection['receipt_lat_sum'], date: jsonCollection['date'], receiptIncinerationToAfrf: jsonCollection['incineration_to_afrf'], receiptIncinerationToAfrfSum: jsonCollection['incineration_to_afrf_sum']));
          // prefs.setDouble("qtyCollection", jsonCollection['quantity_sum']);
        }
        iwmReceiptDataListNotifier.notifyListeners();
      } else {
        iwmReceiptDataListNotifier.value.clear();
        iwmReceiptDataListNotifier.notifyListeners();
      }
    }
  }
}
