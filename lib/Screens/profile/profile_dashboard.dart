import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:recase/recase.dart';
import 'package:resus_test/Screens/profile/update_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utility/MySharedPreferences.dart';
import '../../Utility/utils/constants.dart';

class ProfileDashboard extends StatefulWidget {
  const ProfileDashboard({Key? key}) : super(key: key);

  @override
  State<ProfileDashboard> createState() => _ProfileDashboardState();
}

class _ProfileDashboardState extends State<ProfileDashboard> {
  String sbuDefaultValue = "Choose";
  String departmentDefaultValue = "Choose";
  String projectDefaultValue = "Choose";
  String reportingToDefaultValue = "Choose";

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: kReSustainabilityRed,
          title: const Text(
            'Edit Profile',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'ARIAL',
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                MySharedPreferences.instance
                    .getCityStringValue('SBU_NAME')
                    .then((sbuName) async {
                  MySharedPreferences.instance
                      .getCityStringValue('DEPARTMENT_NAME')
                      .then((departmentName) async {
                    MySharedPreferences.instance
                        .getCityStringValue('Project')
                        .then((projectName) async {
                      MySharedPreferences.instance
                          .getCityStringValue('REPORTING_TO_NAME')
                          .then((reportingToName) async {
                        MySharedPreferences.instance
                            .getCityStringValue('SBU')
                            .then((sbuCode) async {
                          MySharedPreferences.instance
                              .getCityStringValue('DEPARTMENT')
                              .then((depaertmentCode) async {
                            MySharedPreferences.instance
                                .getCityStringValue('PROJECT_CODE')
                                .then((projectCode) async {
                              MySharedPreferences.instance
                                  .getCityStringValue('REPORTING_TO')
                                  .then((reportingtoCode) async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UpdateProfile(
                                            sbuDefaultValue: sbuName,
                                            departmentDefaultValue:
                                                departmentName,
                                            projectDefaultValue: projectName,
                                            reportingToDefaultValue:
                                                reportingToName,
                                            sbuDefaultCode: sbuCode,
                                            departmentDefaultCode:
                                                depaertmentCode,
                                            projectDefaultCode: projectCode,
                                            reportingToDefaultCode:
                                                reportingtoCode,
                                          )),
                                ).then((value) => setState(() {}));
                              });
                            });
                          });
                        });
                      });
                    });
                  });
                });
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10),
            child: (Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 30),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: kReSustainabilityRed,
                        child: FutureBuilder(
                            future: getStringValue('user_name'),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  '${snapshot.data.toString()[0]}'
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontFamily: 'PTSans-Bold',
                                    fontWeight: FontWeight.bold, // italic
                                  ),
                                );
                                // your widget
                              } else {
                                return const CircularProgressIndicator();
                              }
                            }),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder(
                                future: getStringValue('user_name'),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      snapshot.data.toString().titleCase,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontFamily: "ARIAL",
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold, // italic
                                      ),
                                    ); // your widget
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                }),
                            FutureBuilder(
                                future: getStringValue('base_role'),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.hasData) {
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            snapshot.data.toString().titleCase,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                              fontFamily: 'ARIAL',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ); // your widget
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                }),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Divider(
                  height: 0.5,
                  color: Colors.grey[200],
                  indent: 15,
                  endIndent: 15,
                ),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "SBU",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FutureBuilder(
                          future: getStringValue('SBU_NAME'),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data.toString().titleCase,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'ARIAL'),
                              ); // your widget
                            } else {
                              return const CircularProgressIndicator();
                            }
                          }),
                    ],
                  ),
                  trailing: const Text(""),
                ),
                const SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 0.5,
                  color: Colors.grey[200],
                  indent: 15,
                  endIndent: 15,
                ),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Department",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FutureBuilder(
                          future: getStringValue('DEPARTMENT_NAME'),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data.toString().titleCase,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'ARIAL'),
                              ); // your widget
                            } else {
                              return const CircularProgressIndicator();
                            }
                          }),
                    ],
                  ),
                  trailing: const Text(""),
                ),
                const SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 0.5,
                  color: Colors.grey[200],
                  indent: 15,
                  endIndent: 15,
                ),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Project",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FutureBuilder(
                          future: getStringValue('Project'),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data.toString().titleCase,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'ARIAL'),
                              ); // your widget
                            } else {
                              return const CircularProgressIndicator();
                            }
                          }),
                    ],
                  ),
                  trailing: const Text(""),
                ),
                const SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 0.5,
                  color: Colors.grey[200],
                  indent: 15,
                  endIndent: 15,
                ),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "User Reporting To",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FutureBuilder(
                          future: getStringValue('REPORTING_TO_NAME'),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data.toString().titleCase,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'ARIAL'),
                              ); // your widget
                            } else {
                              return const CircularProgressIndicator();
                            }
                          }),
                    ],
                  ),
                  trailing: const Text(""),
                ),
                const SizedBox(
                  height: 20,
                ),
                Divider(
                  height: 0.5,
                  color: Colors.grey[200],
                  indent: 15,
                  endIndent: 15,
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            )),
          ),
        ),
      ),
    );
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }
}
