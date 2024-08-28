import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utility/api_Url.dart';
import '../model/collection_data_list_model.dart';

class GetMswCollectionDataListAPIService extends ChangeNotifier{
  Future<void> getMswCollectionDataListApiCall(CollectionDataListRequestModel irisHomeScreenDataListRequestModel,String fromDate,String toDate, String? siteID ) async {
    final prefs = await SharedPreferences.getInstance();
    String roles = prefs.getString('roleName').toString();
    String sites = prefs.getString("IRIS_SITE_ID").toString();

    irisHomeScreenDataListRequestModel.sbuCode= "MSW";
    irisHomeScreenDataListRequestModel.fromDate=fromDate;
    irisHomeScreenDataListRequestModel.toDate=toDate;
    irisHomeScreenDataListRequestModel.siteId= roles.contains("MSW-Sbuhead") || sites.contains(",")|| roles.contains("BMW-SBUHead") ?
    siteID :
    prefs.getString('IRIS_SITE_ID') ?? '';
    
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    final response = await http.post(Uri.parse(IRIS_DATA_MANAGEMENT),
        body: jsonEncode(irisHomeScreenDataListRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      if (response.body.isNotEmpty) {
        prefs.setDouble("qtyCollectionMswSum", 0.0);
        mswCollectionDataListValueNotifier.value.clear();
        for (Map jsonCollection in json.decode(response.body)) {
          mswCollectionDataListValueNotifier.value.add(
              CollectionDataListResponseModel(
                  collectionDate: jsonCollection["date"],
                  collectionQty: jsonCollection["quantity"],
                  qtySum: jsonCollection["quantity_sum"]));
                  prefs.setDouble("qtyCollectionMswSum", mswCollectionDataListValueNotifier.value.first.qtySum!);
                  
        }
        mswCollectionDataListValueNotifier.notifyListeners();
      }else{
        prefs.setDouble("qtyCollectionMswSum", 0.0);
        mswCollectionDataListValueNotifier.value.clear();
        mswCollectionDataListValueNotifier.notifyListeners();
        print("................No Collection Data Found +++++++++##########");
      }
    }else{
      prefs.setDouble("qtyCollectionMswSum", 0.0);
    }
  }
}
