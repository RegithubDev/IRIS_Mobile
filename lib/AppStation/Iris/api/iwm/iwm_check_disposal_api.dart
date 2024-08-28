import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Utility/api_Url.dart';
import '../../model/iwm/iwm_disposal_data_model.dart';

class GetIwmCheckDisposalDataListAPIService extends ChangeNotifier{
  Future<void> getIwmCheckDisposalDataListApiCall(
      IwmDisposalDataListRequestModel iwmDisposalDataListRequestModel,
      String? siteID) async {
    final prefs = await SharedPreferences.getInstance();
    String roles = prefs.getString('roleName').toString();
    String sites = prefs.getString("IRIS_SITE_ID").toString();
    iwmDisposalDataListRequestModel.sbuCode = "IWM";
    iwmDisposalDataListRequestModel.fromDate = "";
    iwmDisposalDataListRequestModel.toDate = "";
    iwmDisposalDataListRequestModel.siteId =
    roles.contains("SBUHead") || sites.contains(",")
        ? siteID
        : prefs.getString('IRIS_SITE_ID') ?? "";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    final response = await http.post(Uri.parse(IRIS_DATA_MANAGEMENT),
        body: jsonEncode(iwmDisposalDataListRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      if (response.body.isNotEmpty) {
        iwmCheckDisposalDataListNotifier.value.clear();
        for (Map jsonCollection in json.decode(response.body)) {
          iwmCheckDisposalDataListNotifier.value.add(
              IwmDisposalDataListResponseModel(
                  disposalTotalWaste: jsonCollection["disposal_total_waste"],
                  disposalDlf: jsonCollection["disposal_dlf"],
                  disposalLat: jsonCollection["disposal_lat"],
                  disposalIncineration: jsonCollection["disposal_incineration"],
                  disposalAfrf: jsonCollection["disposal_afrf"],
                  disposalIncinerationToAfrf: jsonCollection["incineration_to_afrf"],
                  disposalRecycQtyTotal: jsonCollection["recycling_qty_total"],
                  disposalRecycQtyAfrf: jsonCollection["recycling_qty_afrf"],
                  disposalRecycQtyInc: jsonCollection["recycling_qty_inc"],
                  disposalTotalWasteSum: jsonCollection["disposal_total_waste_sum"],
                  disposalDlfSum: jsonCollection["disposal_dlf_sum"],
                  disposalLatSum: jsonCollection["disposal_lat_sum"],
                  disposalAfrfSum: jsonCollection["disposal_afrf_sum"],
                  disposalIncinerationSum: jsonCollection["disposal_incineration_sum"],
                  disposalIncinerationToAfrfSum: jsonCollection["incineration_to_afrf_sum"],
                  disposalRecycQtyTotalSum: jsonCollection["recycling_qty_total_sum"],
                  disposalRecycQtyIncSum: jsonCollection["recycling_qty_inc_sum"],
                  disposalRecycQtyAfrfSum: jsonCollection["recycling_qty_afrf_sum"],
                  date: jsonCollection["date"]));

          prefs.setString("disposalLastDate", iwmCheckDisposalDataListNotifier.value.last.date);
        }
        iwmCheckDisposalDataListNotifier.notifyListeners();
      } else {
        iwmCheckDisposalDataListNotifier.value.clear();
        iwmCheckDisposalDataListNotifier.notifyListeners();
      }
    }
  }
}
