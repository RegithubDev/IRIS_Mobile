import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Utility/api_Url.dart';
import '../data_models/msw_distribute_data_list_model.dart';


class GetMswDistributeDataListAPIService extends ChangeNotifier{
  Future<void> getMswDistributeDataListApiCall(MswDistributeDataListRequestModel mswDistributeRequestModel,String fromDate,String toDate, String siteID ) async {
    final prefs = await SharedPreferences.getInstance();
    String roles = prefs.getString('roleName').toString();
    String sites = prefs.getString("IRIS_SITE_ID").toString();

    mswDistributeRequestModel.fromDate=fromDate;
    mswDistributeRequestModel.toDate=toDate;
    mswDistributeRequestModel.siteId= roles.contains("MSW-Sbuhead") || roles.contains("BMW-SBUHead") || sites.contains(",") ? siteID : prefs.getString('IRIS_SITE_ID') ?? '';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    final response = await http.post(Uri.parse(IRIS_DATA_MANAGEMENT),
        body: jsonEncode(mswDistributeRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      if (response.body.isNotEmpty) {
        mswDistributeDataListValueNotifier.value.clear();
        for (Map jsonCollection in json.decode(response.body)) {
          mswDistributeDataListValueNotifier.value.add(
              MswDistributeDataListResponseModel(
                date: jsonCollection['date'],
                compost: jsonCollection['compost'],
                rdf: jsonCollection['rdf'],
                recyclables: jsonCollection['recyclables'],
                inserts: jsonCollection['inserts'],
                total_waste: jsonCollection['total_waste'],
              ));
        }
        mswDistributeDataListValueNotifier.notifyListeners();
      }else{
        mswDistributeDataListValueNotifier.value.clear();
        mswDistributeDataListValueNotifier.notifyListeners();
      }
    }
  }
}
