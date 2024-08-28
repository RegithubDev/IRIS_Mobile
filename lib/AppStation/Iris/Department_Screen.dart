import 'package:flutter/material.dart';
import 'package:resus_test/AppStation/Iris/api/get_roles_api_service.dart';
import 'package:resus_test/AppStation/Iris/model/user_roles_model.dart';
import 'package:resus_test/Screens/home/home.dart';
import 'package:resus_test/Utility/showLoader.dart';
import 'package:resus_test/Utility/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'api/get_iris_home_api_service.dart';
import 'iris_home_screen.dart';
import 'model/iris_home_model.dart';

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({super.key});

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  late IRISHomeRequestModel irisHomeRequestModel;
  late UserRoleRequestModel userRoleRequestModel;

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    irisHomeRequestModel = IRISHomeRequestModel();
    GetIRISHomeAPIService getIRISHomeAPIService = GetIRISHomeAPIService();
    getIRISHomeAPIService.getIrisHomeApiCall(irisHomeRequestModel);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (value) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Home(
                    googleSignInAccount: null,
                    userId: "",
                    emailId: "",
                    initialSelectedIndex: 4)));
      },
      child: Scaffold(
        backgroundColor: kReSustainabilityRed,
        appBar: PreferredSize(
          preferredSize: const Size(0, 70),
          child: AppBar(
            centerTitle: true,
            title: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                "IRIS",
                style: TextStyle(
                    fontFamily: "ARIAL",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp),
              ),
            ),
            elevation: 0,
            backgroundColor: kReSustainabilityRed,
            leading: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 25.0,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Home(
                        googleSignInAccount: null,
                        userId: "",
                        emailId: "",
                        initialSelectedIndex: 4),
                  ));
                },
              ),
            ),
          ),
        ),
        body: ValueListenableBuilder(
            valueListenable: userRoleValueNotifier,
            builder: (BuildContext ctx, String userRole, Widget? child) {
              if (userRole.isNotEmpty) {
                return Column(
                  children: [
                    const Divider(
                      height: 10.0,
                      color: Colors.white,
                      thickness: 2.0,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Card(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0, bottom: 10.0, right: 5.0, left: 5.0),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      getRole("BMW").then((value) {
                                        value.contains("BMW-Site Ops Head") ||
                                                value
                                                    .contains("BMW-SiteHead") ||
                                                value.contains("BMW-SBUHead")
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        IrisHomeScreen(
                                                            sbuCode: "BMW",
                                                            userRole: value,
                                                            departmentName:
                                                                "BMW")))
                                            : showCustomAlertDialog(context);
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 15.0,
                                          left: 40.0,
                                          top: 20.0,
                                          bottom: 15.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "BMW",
                                              style: TextStyle(
                                                  fontFamily: "ARIAL",
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.sp),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: kGreyTextColor,
                                            )
                                          ]),
                                    ),
                                  ),
                                  const Divider(
                                    height: 10.0,
                                    color: kGreyDivider,
                                    thickness: 1.5,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      getRole("IWM").then((value) {
                                        value.contains("IWM")
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        IrisHomeScreen(
                                                            sbuCode: "IWM",
                                                            userRole: value,
                                                            departmentName:
                                                                "IWM")))
                                            : showCustomAlertDialog(context);
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 15.0,
                                          left: 40.0,
                                          top: 20.0,
                                          bottom: 15.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "IWM",
                                              style: TextStyle(
                                                  fontFamily: "ARIAL",
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.sp),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: kGreyTextColor,
                                            )
                                          ]),
                                    ),
                                  ),
                                  const Divider(
                                    height: 10.0,
                                    color: kGreyDivider,
                                    thickness: 1.5,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      getRole("MSW").then((value) {
                                        value.contains("CNT") ||
                                                value.contains("PND") ||
                                                value
                                                    .contains("MSW-Sitehead") ||
                                                value.contains("MSW-Sbuhead")
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        IrisHomeScreen(
                                                            sbuCode: "MSW",
                                                            userRole: value,
                                                            departmentName:
                                                                "MSW")))
                                            : showCustomAlertDialog(context);
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 15.0,
                                          left: 40.0,
                                          top: 20.0,
                                          bottom: 15.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "C & T  /  P & D",
                                              style: TextStyle(
                                                  fontFamily: "ARIAL",
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.sp),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: kGreyTextColor,
                                            )
                                          ]),
                                    ),
                                  ),
                                  const Divider(
                                    height: 10.0,
                                    color: kGreyDivider,
                                    thickness: 1.5,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      getRole("MSW").then((value) {
                                        value.contains("WTE") ||
                                                value.contains("MSW-Sbuhead") ||
                                                value.contains("MSW-Sitehead")
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        IrisHomeScreen(
                                                            sbuCode: "MSW",
                                                            userRole: value,
                                                            departmentName:
                                                                "WTE")))
                                            : showCustomAlertDialog(context);
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 15.0,
                                          left: 40.0,
                                          top: 20.0,
                                          bottom: 15.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "WTE",
                                              style: TextStyle(
                                                  fontFamily: "ARIAL",
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.sp),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: kGreyTextColor,
                                            )
                                          ]),
                                    ),
                                  ),
                                  const Divider(
                                    height: 10.0,
                                    color: kGreyDivider,
                                    thickness: 1.5,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      getRole("CND").then((value) {
                                        value.toString() != ""
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        IrisHomeScreen(
                                                            sbuCode: "CND",
                                                            userRole: value,
                                                            departmentName:
                                                                "CND")))
                                            : showCustomAlertDialog(context);
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 15.0,
                                          left: 40.0,
                                          top: 20.0,
                                          bottom: 15.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "C & D",
                                              style: TextStyle(
                                                  fontFamily: "ARIAL",
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.sp),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: kGreyTextColor,
                                            )
                                          ]),
                                    ),
                                  ),
                                  const Divider(
                                    height: 10.0,
                                    color: kGreyDivider,
                                    thickness: 1.5,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      getRole("CRM").then((value) {
                                        value.toString() != ""
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        IrisHomeScreen(
                                                            sbuCode: "CRM",
                                                            userRole: value,
                                                            departmentName:
                                                                "CRM")))
                                            : showCustomAlertDialog(context);
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 15.0,
                                          left: 40.0,
                                          top: 20.0,
                                          bottom: 15.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "CRM",
                                              style: TextStyle(
                                                  fontFamily: "ARIAL",
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.sp),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: kGreyTextColor,
                                            )
                                          ]),
                                    ),
                                  ),
                                  const Divider(
                                    height: 10.0,
                                    color: kGreyDivider,
                                    thickness: 1.5,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      getRole("Plastics").then((value) {
                                        value.toString() != ""
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        IrisHomeScreen(
                                                            sbuCode: "Plastics",
                                                            userRole: value,
                                                            departmentName:
                                                                "Plastics")))
                                            : showCustomAlertDialog(context);
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 15.0,
                                          left: 40.0,
                                          top: 20.0,
                                          bottom: 15.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Plastics",
                                              style: TextStyle(
                                                  fontFamily: "ARIAL",
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.sp),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: kGreyTextColor,
                                            )
                                          ]),
                                    ),
                                  ),
                                  const Divider(
                                    height: 10.0,
                                    color: kGreyDivider,
                                    thickness: 1.5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              } else {
                return ShowLoader();
              }
            }),
      ),
    );
  }

  void showCustomAlertDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Image.asset(
              'assets/icons/warning.png',
              height: 100.0,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'You are not Authorized',
                  style: TextStyle(
                    fontFamily: "ARIAL",
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 2.h,
                ),
                const Text('It seems like you don’t have permission to use',
                    style: TextStyle(
                      fontFamily: "ARIAL",
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center),
              ],
            ),
            actions: <Widget>[
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      backgroundColor: kReSustainabilityRed,
                      elevation: 3.0,
                      padding: const EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 40.0, right: 40.0)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Go Back',
                    style: TextStyle(color: kWhite, fontSize: 14.0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  getRole(String sbu) async {
    String roles = "";
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userRoleRequestModel = UserRoleRequestModel();
    GetUserRoleAPIService getUserRoleAPIService = GetUserRoleAPIService();
    await getUserRoleAPIService.getUserRoleApiCall(userRoleRequestModel, sbu);
    for (int i = 0; i < userRoleNotifier.value.length; i++) {
      roles = userRoleNotifier.value.map((role) => role.roleName).join(',');
    }

    userRoleNotifier.value.isNotEmpty
        ? prefs.setString("roleName", roles)
        : null;

    return userRoleNotifier.value.isNotEmpty ? roles : "";
  }
}
