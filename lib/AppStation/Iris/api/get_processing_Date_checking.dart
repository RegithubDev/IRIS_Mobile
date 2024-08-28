import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utility/api_Url.dart';
import '../model/processing_data_list_model.dart';

class GetProcessingDateCheckingListAPIService extends ChangeNotifier{
  Future<void> getProcessingDateCheckingListApiCall(ProcessingDataListRequestModel processingDataListRequestModel,String startDate,String endDate,String sbuCode, String siteID) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String sites = prefs.getString("IRIS_SITE_ID").toString();
    processingDataListRequestModel.sbuCode=sbuCode;
    processingDataListRequestModel.fromDate=startDate;
    processingDataListRequestModel.toDate=endDate;
    processingDataListRequestModel.siteId=sites.contains(",") ? siteID : prefs.getString('IRIS_SITE_ID') ?? '';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    final response = await http.post(Uri.parse(IRIS_DATA_MANAGEMENT),
        body: jsonEncode(processingDataListRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      if (response.body.isNotEmpty) {
        processingDateChecking.value.clear();
        for (Map jsonCollection in json.decode(response.body)) {
          processingDateChecking.value.add(
              ProcessingDataListResponseModel(
                  processingDate: jsonCollection["date"], totalIncinerationQty: jsonCollection["total_incieration"], totalAutoClaveQty: jsonCollection["total_autoclave"], totalWeightQty: jsonCollection["total_waste"], totalWasteSum: jsonCollection["total_waste_sum"], totalIncinerationSum: jsonCollection["total_incieration_sum"], totalAutoclaveSum: jsonCollection["total_autoclave_sum"]));
        }
        processingDateChecking.notifyListeners();
      }else{
        processingDateChecking.value.clear();
        processingDateChecking.notifyListeners();
        print("................No Processing Data Found +++++++++##########");
      }
    }
  }
}
