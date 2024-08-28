import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Utility/api_Url.dart';
import '../data_models/msw_distribute_data_list_model.dart';

class GetMswDistributeDataListAPIService extends ChangeNotifier{
  Future<void> getMswPndDataListApiCall(MswDistributeDataListRequestModel mswDistributeRequestModel,String fromDate,String toDate ) async {
    final prefs = await SharedPreferences.getInstance();
    mswDistributeRequestModel.fromDate=fromDate;
    mswDistributeRequestModel.toDate=toDate;
    mswDistributeRequestModel.siteId= prefs.getString('IRIS_SITE_ID') ?? '';

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
        mswDistributeDateChecking.value.clear();
        for (Map jsonCollection in json.decode(response.body)) {
          mswDistributeDateChecking.value.add(
              MswDistributeDataListResponseModel(
                date: jsonCollection['date'],
                compost: jsonCollection['compost'],
                rdf: jsonCollection['rdf'],
                recyclables: jsonCollection['recyclables'],
                inserts: jsonCollection['inserts'],
                total_waste: jsonCollection['total_waste'],
              ));
        }
        mswDistributeDateChecking.notifyListeners();
      }else{
        mswDistributeDateChecking.value.clear();
        mswDistributeDateChecking.notifyListeners();
      }
    }
  }
}
