import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utility/api_Url.dart';
import '../model/recyclable_data_list_model.dart';

class GetRecyclableDataListAPIService extends ChangeNotifier{
  Future<void> getRecyclableDataListApiCall(RecyclableDataListRequestModel recyclableDataListRequestModel,String startDate,String endDate,String sbuCode,String siteID) async {
    final prefs = await SharedPreferences.getInstance();
    String roles = prefs.getString('roleName').toString();
    String sites = prefs.getString("IRIS_SITE_ID").toString();
    recyclableDataListRequestModel.sbuCode=sbuCode;
    recyclableDataListRequestModel.fromDate=startDate;
    recyclableDataListRequestModel.toDate=endDate;
    recyclableDataListRequestModel.siteId= sites.contains(",") || roles.contains("MSW-Sbuhead") || roles.contains("BMW-SBUHead") ? siteID: prefs.getString('IRIS_SITE_ID') ?? '';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    final response = await http.post(Uri.parse(IRIS_DATA_MANAGEMENT),
        body: jsonEncode(recyclableDataListRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      recyclableDataListValueNotifier.value.clear();
      if (response.body.isNotEmpty) {
        prefs.setDouble("qtyRecyclable", 0.0);
        for (Map jsonCollection in json.decode(response.body)) {
          recyclableDataListValueNotifier.value.add(
              RecyclableDataListResponseModel(
                recyclableDate: jsonCollection["date"],
                recyclableQty: jsonCollection["total_recylable"],
                glassQty: jsonCollection["total_glass"],
                plasticQty: jsonCollection["total_plastic"],
                bagsQty: jsonCollection["total_bags"],
                cardBoardQty: jsonCollection["total_cardboard"],
                totalMaterialSum: jsonCollection["total_materials_sum"].toString(),
                totalRecyclableSum: jsonCollection["total_recylable_sum"],
                totalBagsSum: jsonCollection["total_bags_sum"].toString(),
                totalGlassSum: jsonCollection["total_glass_sum"].toString(),
                totalCardBoardSum: jsonCollection["total_cardboard_sum"].toString(),
                totalPlasticSum: jsonCollection["total_plastic_sum"].toString(),
              ));
          prefs.setDouble("qtyRecyclable", recyclableDataListValueNotifier.value.first.totalRecyclableSum!);
        }
        recyclableDataListValueNotifier.notifyListeners();
      }else{
        prefs.setDouble("qtyRecyclable", 0.0);
        recyclableDataListValueNotifier.value.clear();
        recyclableDataListValueNotifier.notifyListeners();
      }
    }else{
      prefs.setDouble("qtyRecyclable", 0.0);
    }
  }
}
