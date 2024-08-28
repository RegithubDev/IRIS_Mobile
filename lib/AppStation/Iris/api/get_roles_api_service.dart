import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:resus_test/AppStation/Iris/model/user_roles_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utility/api_Url.dart';

class GetUserRoleAPIService extends ChangeNotifier{
  Future<void> getUserRoleApiCall(UserRoleRequestModel userRoleRequestModel, String sbu) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
   userRoleRequestModel.sbuCode = sbu;
   userRoleRequestModel.roles = prefs.getString("IRIS_USER_ROLE").toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    final response = await http.post(Uri.parse(GET_ROLES_DETAILS),
        body: jsonEncode(userRoleRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      if (response.body.isNotEmpty) {
        userRoleNotifier.value.clear();
        for (Map jsonCollection in json.decode(response.body)) {
          userRoleNotifier.value.add(
            UserRoleResponseModel(siteId: jsonCollection['id'], siteName: jsonCollection['sbu_code'], roleName: jsonCollection['role_name'])
          );
        }
        userRoleNotifier.notifyListeners();
      }
    }else{
      userRoleNotifier.value.clear();
      userRoleNotifier.notifyListeners();
    }
  }
}
