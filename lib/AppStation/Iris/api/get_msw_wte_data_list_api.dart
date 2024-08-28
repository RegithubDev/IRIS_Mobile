import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:resus_test/AppStation/Iris/model/msw_wte_data_list_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utility/api_Url.dart';

class GetMswWteDataListAPIService extends ChangeNotifier{
  Future<void> getMswWteDataListApiCall(MswWteDataListRequestModel mswWteRequestModel,String fromDate,String toDate, String siteID) async {
    final prefs = await SharedPreferences.getInstance();
    String roles = prefs.getString('roleName').toString();
    mswWteRequestModel.fromDate=fromDate;
    mswWteRequestModel.toDate=toDate;
    mswWteRequestModel.siteId=  roles.contains("MSW-Sbuhead") || roles.contains("BMW-SBUHead") ? siteID : prefs.getString('IRIS_SITE_ID') ?? '';

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
        mswWteDataListValueNotifier.value.clear();
        for (Map jsonCollection in json.decode(response.body)) {
          mswWteDataListValueNotifier.value.add(
              MswWteDataListResponseModel(
                  rdfReceipt: jsonCollection['rdf_receipt'] ?? '0',
                  rdfCombusted: jsonCollection['rdf_combusted'] ?? '0',
                  auxillaryConsumption: jsonCollection['auxiliary_consumption'] ?? '0',
                  streamGeneration: jsonCollection['steam_generation'] ?? '0',
                  powerGeneration: jsonCollection['power_produced'] ?? '0',
                  powerExport: jsonCollection['power_export'] ?? '0',
                  powerGenerationCapacity: jsonCollection['plant_generation_capacity'] ?? '0',
                  plantLoadFactor: jsonCollection['plant_load_factor'] ?? '0',
                  bottomAsh: jsonCollection['bottom_ash'] ?? '0',
                  flyAsh: jsonCollection['fly_ash'] ?? '0',
                  totalAsh: jsonCollection['ash_generated'] ?? '0',
                  mswWteDate: jsonCollection['date'],
                  rdfReceiptSum: jsonCollection['rdf_receipt_sum'] ?? '0',
                  rdfCombustedSum: jsonCollection['rdf_combusted_sum'] ?? '0',
                  ashGeneratedSum: jsonCollection['ash_generated_sum'] ?? '0',
                  streamGenerationSum: jsonCollection['steam_generation_sum'] ?? '0',
                  powerGenerationSum: jsonCollection['power_produced_sum'] ?? '0',
                  powerExportSum: jsonCollection['power_export_sum'] ?? '0',
                bottomAshSum: jsonCollection['bottom_ash_sum'] ?? '0',
                flyAshSum: jsonCollection['fly_ash_sum'] ?? '0'
              ));
        }
        mswWteDataListValueNotifier.notifyListeners();
      }else{
        mswWteDataListValueNotifier.value.clear();
        mswWteDataListValueNotifier.notifyListeners();
      }
    }
  }
}
