import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Utility/api_Url.dart';
import '../data_models/msw_process_data_list_model.dart';

class GetMswProcessDateCheckingListAPIService extends ChangeNotifier {
  Future<void> getMswProcessDateListApiCall(
      MswProcessingDataListRequestModel mswProcessRequestModel,
      String fromDate,
      String toDate) async {
    final prefs = await SharedPreferences.getInstance();
    mswProcessRequestModel.fromDate = fromDate;
    mswProcessRequestModel.toDate = toDate;
    mswProcessRequestModel.siteId = prefs.getString('IRIS_SITE_ID') ?? '';

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
        mswProcessingDateChecking.value.clear();
        for (Map jsonCollection in json.decode(response.body)) {
          mswProcessingDateChecking.value.add(MswProcessDataListResponseModel(
            date: jsonCollection['date'],
            total_compost: jsonCollection['total_compost'],
            total_rdf: jsonCollection['total_rdf'],
            total_recylables: jsonCollection['total_recylables'],
            total_inerts: jsonCollection['total_inerts'],
            total_waste: jsonCollection['total_waste'],
          ));
        }
        mswProcessingDateChecking.notifyListeners();
      } else {
        mswProcessingDateChecking.value.clear();
        mswProcessingDateChecking.notifyListeners();
      }
    }
  }
}
