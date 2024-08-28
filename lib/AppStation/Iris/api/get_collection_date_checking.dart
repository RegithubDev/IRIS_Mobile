import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utility/api_Url.dart';
import '../model/collection_data_list_model.dart';

class GetCollectionDateCheckingAPIService extends ChangeNotifier{
  Future<void> getCollectionDateCheckingListApiCall(
      CollectionDataListRequestModel irisHomeScreenDataListRequestModel,
      String fromDate,
      String toDate,
      String sbuCode,
      String siteID) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String sites = prefs.getString("IRIS_SITE_ID").toString();
    irisHomeScreenDataListRequestModel.sbuCode = sbuCode;
    irisHomeScreenDataListRequestModel.fromDate = fromDate;
    irisHomeScreenDataListRequestModel.toDate = toDate;
    irisHomeScreenDataListRequestModel.siteId =
        sites.contains(",") ? siteID : prefs.getString('IRIS_SITE_ID') ?? '';
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
        for (Map jsonCollection in json.decode(response.body)) {
          collectionDateChecking.value.add(CollectionDataListResponseModel(
              collectionDate: jsonCollection["date"],
              collectionQty: jsonCollection["quantity"].toString(),
              qtySum: jsonCollection["quantity_sum"]));
        }
        collectionDateChecking.notifyListeners();
      } else {
        collectionDateChecking.value.clear();
        collectionDateChecking.notifyListeners();
        print("................No Collection Data Found +++++++++##########");
      }
    }
  }
}
