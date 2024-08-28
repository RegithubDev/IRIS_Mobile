import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:resus_test/AppStation/Iris/model/site_data_list_model.dart';

import '../../../Utility/api_Url.dart';

class GetSiteListAPIService extends ChangeNotifier{
  Future<void> getSiteListApiCall(SiteDataListRequestModel siteDataListRequestModel, String sbu) async {
    siteDataListRequestModel.sbuCode= sbu;

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    final response = await http.post(Uri.parse(IRIS_SITE_LIST),
        body: jsonEncode(siteDataListRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      if (response.body.isNotEmpty) {
        siteDataListValueNotifier.value.clear();
        for (Map jsonCollection in json.decode(response.body)) {
          siteDataListValueNotifier.value.add(
              SiteDataListResponseModel(
                  siteId: jsonCollection["id"],
                  siteName: jsonCollection["site_name"]));
        }

        siteDataListValueNotifier.notifyListeners();
      }
    }
  }
}
