
import 'package:flutter/foundation.dart';

ValueNotifier<List<UserRoleResponseModel>> userRoleNotifier =
ValueNotifier([]);

class UserRoleResponseModel {
  final String? siteId;
  final String? siteName;
  final String? roles;
  final String roleName;

  UserRoleResponseModel({required this.siteId,required this.siteName, this.roles,required this.roleName});

}
class UserRoleRequestModel {
  String? sbuCode;
  String? roles;

  UserRoleRequestModel(
      {this.sbuCode, this.roles});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": sbuCode,
      "roles": roles
    };
    return map;
  }
}


