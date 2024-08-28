import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utility/api_Url.dart';
import '../model/collection_data_list_model.dart';

class GetCollectionDataListAPIService extends ChangeNotifier {
  Future<void> getCollectionDataListApiCall(
      CollectionDataListRequestModel irisHomeScreenDataListRequestModel,
      String fromDate,
      String toDate,
      String? siteID) async {
    final prefs = await SharedPreferences.getInstance();
    String roles = prefs.getString('roleName').toString();
    String sites = prefs.getString("IRIS_SITE_ID").toString();
    irisHomeScreenDataListRequestModel.sbuCode = "BMW";
    irisHomeScreenDataListRequestModel.fromDate = fromDate;
    irisHomeScreenDataListRequestModel.toDate = toDate;
    irisHomeScreenDataListRequestModel.siteId = roles.contains("MSW-Sbuhead") ||
            roles.contains("BMW-SBUHead") ||
            sites.contains(",")
        ? siteID
        : prefs.getString('IRIS_SITE_ID') ?? '';

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
        prefs.setDouble("qtyCollection", 0.0);
        collectionDataListValueNotifier.value.clear();
        for (Map jsonCollection in json.decode(response.body)) {
          collectionDataListValueNotifier.value.add(
              CollectionDataListResponseModel(
                  collectionDate: jsonCollection["date"],
                  collectionQty: jsonCollection["quantity"],
                  qtySum: jsonCollection["quantity_sum"]));
          prefs.setDouble("qtyCollection",
              collectionDataListValueNotifier.value.first.qtySum!);
        }
        collectionDataListValueNotifier.notifyListeners();
      } else {
        prefs.setDouble("qtyCollection", 0.0);
        collectionDataListValueNotifier.value.clear();
        collectionDataListValueNotifier.notifyListeners();
        print("................No Collection Data Found +++++++++##########");
      }
    } else {
      prefs.setDouble("qtyCollection", 0.0);
    }
  }
}
