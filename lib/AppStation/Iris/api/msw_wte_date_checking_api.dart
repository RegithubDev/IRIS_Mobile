import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:resus_test/AppStation/Iris/model/msw_wte_data_list_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utility/api_Url.dart';

class GetMswWteDateCheckingListAPIService extends ChangeNotifier{
  Future<void> getMswWteDateListApiCall(MswWteDataListRequestModel mswWteRequestModel,String fromDate,String toDate, String siteID) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String sites = prefs.getString("IRIS_SITE_ID").toString();
    mswWteRequestModel.fromDate=fromDate;
    mswWteRequestModel.toDate=toDate;
    mswWteRequestModel.siteId = sites.contains(",") ? siteID : prefs.getString('IRIS_SITE_ID') ?? '';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    final response = await http.post(Uri.parse(IRIS_DATA_MANAGEMENT),
        body: jsonEncode(mswWteRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      if (response.body.isNotEmpty) {
        mswWteDateChecking.value.clear();
        for (Map jsonCollection in json.decode(response.body)) {
          mswWteDateChecking.value.add(
              MswWteDataListResponseModel(
                  rdfReceipt: jsonCollection['rdf_receipt'],
                  rdfCombusted: jsonCollection['rdf_combusted'],
                  auxillaryConsumption: jsonCollection['auxiliary_consumption'],
                  streamGeneration: jsonCollection['steam_generation'],
                  powerGeneration: jsonCollection['power_produced'],
                  powerExport: jsonCollection['power_export'],
                  powerGenerationCapacity: jsonCollection['plant_generation_capacity'],
                  plantLoadFactor: jsonCollection['plant_load_factor'] ?? '0',
                  bottomAsh: jsonCollection['bottom_ash'] ?? '0',
                  flyAsh: jsonCollection['fly_ash'] ?? '0',
                  totalAsh: jsonCollection['ash_generated'] ?? '0',
                  mswWteDate: jsonCollection['date']
              ));
        }
        mswWteDateChecking.notifyListeners();
      }else{
        mswWteDateChecking.value.clear();
        mswWteDateChecking.notifyListeners();
      }
    }
  }
}
