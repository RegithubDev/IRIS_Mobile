import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Utility/api_Url.dart';
import '../data_models/msw_process_data_list_model.dart';

class GetMswPndDataListAPIService extends ChangeNotifier {
  Future<void> getMswPndDataListApiCall(
      MswProcessingDataListRequestModel mswProcessRequestModel,
      String fromDate,
      String toDate,
      String siteID) async {
    final prefs = await SharedPreferences.getInstance();
    String roles = prefs.getString('roleName').toString();
    String sites = prefs.getString("IRIS_SITE_ID").toString();
    mswProcessRequestModel.fromDate = fromDate;
    mswProcessRequestModel.toDate = toDate;
    mswProcessRequestModel.siteId = roles.contains("MSW-Sbuhead") ||
            roles.contains("BMW-SBUHead") ||
            sites.contains(",")
        ? siteID
        : prefs.getString('IRIS_SITE_ID') ?? '';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    final response = await http.post(Uri.parse(IRIS_DATA_MANAGEMENT),
        body: jsonEncode(mswProcessRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      if (response.body.isNotEmpty) {
        prefs.setDouble("mswProcessQty", 0.0);
        mswProcessingDataListValueNotifier.value.clear();
        for (Map jsonCollection in json.decode(response.body)) {
          mswProcessingDataListValueNotifier.value.add(
              MswProcessDataListResponseModel(
                  date: jsonCollection['date'],
                  total_compost: jsonCollection['total_compost'],
                  total_rdf: jsonCollection['total_rdf'],
                  total_recylables: jsonCollection['total_recylables'],
                  total_inerts: jsonCollection['total_inerts'],
                  total_waste: jsonCollection['total_waste'],
                  qtySum: jsonCollection['total_waste_sum']));
                  prefs.setDouble("mswProcessQty", mswProcessingDataListValueNotifier.value.first.qtySum!);
        }
        mswProcessingDataListValueNotifier.notifyListeners();
      } else {
        prefs.setDouble("mswProcessQty", 0.0);
        mswProcessingDataListValueNotifier.value.clear();
        mswProcessingDataListValueNotifier.notifyListeners();
      }
    }else{
      prefs.setDouble("mswProcessQty", 0.0);
    }
  }
}
