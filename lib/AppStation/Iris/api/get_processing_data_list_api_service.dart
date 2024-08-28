import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utility/api_Url.dart';
import '../model/processing_data_list_model.dart';

class GetProcessingDataListAPIService extends ChangeNotifier{
  Future<void> getProcessingDataListApiCall(ProcessingDataListRequestModel processingDataListRequestModel,String startDate,String endDate,String sbuCode, String siteID) async {
    final prefs = await SharedPreferences.getInstance();
    String roles = prefs.getString('roleName').toString();
    String sites = prefs.getString("IRIS_SITE_ID").toString();
    processingDataListRequestModel.sbuCode=sbuCode;
    processingDataListRequestModel.fromDate=startDate;
    processingDataListRequestModel.toDate=endDate;
    processingDataListRequestModel.siteId= sites.contains(",") || roles.contains("MSW-Sbuhead") || roles.contains("BMW-SBUHead") ? siteID : prefs.getString('IRIS_SITE_ID') ?? '';

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
        prefs.setDouble("qtyIncierationSum", 0.0);
        prefs.setDouble("qtyAutoclaveSum", 0.0);
        processingDataListValueNotifier.value.clear();
        for (Map jsonCollection in json.decode(response.body)) {
          processingDataListValueNotifier.value.add(
              ProcessingDataListResponseModel(
                  processingDate: jsonCollection["date"],
                  totalIncinerationQty: jsonCollection["total_incieration"],
                  totalAutoClaveQty: jsonCollection["total_autoclave"],
                  totalWeightQty: jsonCollection["total_waste"],
                  totalWasteSum: jsonCollection["total_waste_sum"],
                  totalIncinerationSum: jsonCollection["total_incieration_sum"],
                  totalAutoclaveSum: jsonCollection["total_autoclave_sum"]));
          prefs.setDouble("qtyIncierationSum", processingDataListValueNotifier.value.first.totalIncinerationSum!);
          prefs.setDouble("qtyAutoclaveSum", processingDataListValueNotifier.value.first.totalAutoclaveSum!);
        }
        processingDataListValueNotifier.notifyListeners();
      }else{
        prefs.setDouble("qtyIncierationSum", 0.0);
        prefs.setDouble("qtyAutoclaveSum", 0.0);
        processingDataListValueNotifier.value.clear();
        processingDataListValueNotifier.notifyListeners();
        print("................No Processing Data Found +++++++++##########");
      }
    }else{
      prefs.setDouble("qtyIncierationSum", 0.0);
      prefs.setDouble("qtyAutoclaveSum", 0.0);
    }
  }
}
