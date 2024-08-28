
import 'package:flutter/foundation.dart';

ValueNotifier<List<SiteDataListResponseModel>> siteDataListValueNotifier =
ValueNotifier([]);

class SiteDataListResponseModel {
  final String? siteId;
  final String? siteName;

  SiteDataListResponseModel({this.siteId,this.siteName});

}
class SiteDataListRequestModel {
  String? sbuCode;

  SiteDataListRequestModel(
      {this.sbuCode});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": sbuCode,
      "startIndex" : "0",
      "offset" : "100"
    };
    return map;
  }
}


