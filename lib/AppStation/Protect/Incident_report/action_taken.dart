import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:recase/recase.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/submit_incident.dart';
import 'package:resus_test/Utility/internetCheck.dart';

import '../../../Utility/MySharedPreferences.dart';
import '../../../Utility/gps_dialogbox.dart';
import '../../../Utility/network_error_dialogbox.dart';
import '../../../Utility/utils/constants.dart';
import '../api_call/actionTakenApiCall.dart';
import '../models/CProtect.dart';
import '../sort/action_taken_sort_popup.dart';
import 'incident_form_view.dart';
import 'incident_history.dart';

class ActionTaken extends StatefulWidget {
  const ActionTaken({Key? key}) : super(key: key);

  @override
  State<ActionTaken> createState() => _ActionTakenState();
}

class _ActionTakenState extends State<ActionTaken> {
  TextEditingController searchController = TextEditingController();

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  bool _isFirstLoadRunning = false;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  late ScrollController _controller;
  late List<CProtect> listProtect = [];
  List<CProtect> itemsProtect = [];

  int startIndex = 0;
  int pageIndex = 10;
  int pageLength = 10;

  @override
  void initState() {
    getConnectivity();
    super.initState();
  }

  void _firstLoad() async {
    if (mounted == true) {
      setState(() {
        _isFirstLoadRunning = true;
      });
    }
    MySharedPreferences.instance
        .getCityStringValue('user_id')
        .then((userid) async {
      MySharedPreferences.instance
          .getCityStringValue('JSESSIONID')
          .then((session) async {
        populateActionTakenList(session, startIndex, pageIndex);
      });
    });
    if (mounted == true) {
      setState(() {
        _isFirstLoadRunning = false;
      });
    }
  }

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false) {
      listProtect.clear();
      if (mounted == true) {
        setState(() {
          _isLoadMoreRunning =
              true; // Display a progress indicator at the bottom
        });
      }
      startIndex = pageIndex;
      pageIndex = startIndex + pageLength;

      MySharedPreferences.instance
          .getCityStringValue('user_id')
          .then((userid) async {
        MySharedPreferences.instance
            .getCityStringValue('JSESSIONID')
            .then((session) async {
          var isConnected = await Future.value(checkInternetConnection())
              .timeout(const Duration(seconds: 2));
          if (!isConnected) {
            // ignore: use_build_context_synchronously
            showDialog(
                useRootNavigator: false,
                barrierDismissible: false,
                context: context,
                builder: (_) => const NetworkErrorDialog());
            return;
          }
          ActionTakenApiCall obj = ActionTakenApiCall(session);
          var response = await obj.callActionTakenAPi(startIndex, pageIndex);
          if (response.body == "[]") {
            if (mounted == true) {
              setState(() {
                _hasNextPage = false;
                _isLoadMoreRunning = false;
              });
            }
            return;
          }
          for (Map json in json.decode(response.body)) {
            if (json["status"] == null) {
              json["status"] = '';
            }
            if (json["approver_type"] == null) {
              json["approver_type"] = '';
            }
            if (json["approver_name"] == null) {
              json["approver_name"] = '';
            }
            if (json["created_date"] == null) {
              json["created_date"] = '';
            }
            if (json["document_code"] == null) {
              json["document_code"] = '';
            }
            if (json["incident_type"] == null) {
              json["incident_type"] = '';
            }
            if (json["project_name"] == null) {
              json["project_name"] = '';
            }
            if (json["department_name"] == null) {
              json["department_name"] = '';
            }
            if (json["user_name"] == null) {
              json["user_name"] = '';
            }
            if (json["email_id"] == null) {
              json["email_id"] = '';
            }
            if (json["risk_type"] == null) {
              json["risk_type"] = '';
            }
            if (json["incident_category"] == null) {
              json["incident_category"] = '';
            }
            if (json["description"] == null) {
              json["description"] = '';
            }
            if (json["action_taken"] == null) {
              json["action_taken"] = '';
            }
            listProtect.add(CProtect.fromJson(json));
          }
          if (listProtect.isNotEmpty) {
            if (mounted == true) {
              setState(() {
                itemsProtect.addAll(listProtect);
              });
            }
          } else {
            if (mounted == true) {
              setState(() {
                _hasNextPage = false;
                _isLoadMoreRunning = false;
              });
            }
          }
          if (mounted == true) {
            setState(() {
              _isLoadMoreRunning = false;
            });
          }
        });
      });
    }
  }

  getInit() {
    _firstLoad();
    _controller = ScrollController()..addListener(_loadMore);
  }

  showDialogBox() => showCupertinoDialog<String>(
        barrierDismissible: false,
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) => PopScope(
          canPop: false,
          child: CupertinoAlertDialog(
            title: const Text('No Connection'),
            content: const Text('Please check your internet connectivity'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.pop(context, 'Cancel');
                  if (mounted == true) {
                    setState(() => isAlertSet = false);
                  }
                  isDeviceConnected = await Future.value(
                          InternetCheck().checkInternetConnection())
                      .timeout(const Duration(seconds: 2));
                  if (!isDeviceConnected && isAlertSet == false) {
                    showDialogBox();
                    if (mounted == true) {
                      setState(() => isAlertSet = true);
                    }
                  } else {
                    getInit();
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );

  getConnectivity() async {
    isDeviceConnected =
        await Future.value(InternetCheck().checkInternetConnection())
            .timeout(const Duration(seconds: 2));
    if (!isDeviceConnected && isAlertSet == false) {
      showDialogBox();
      setState(() => isAlertSet = true);
    } else {
      getInit();
    }
  }

  Future<bool> checkInternetConnection() async {
    bool isConnected = true;
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
    }
    return isConnected;
  }

  @override
  void dispose() {
    //subscription.cancel();
    super.dispose();
  }

  void populateActionTakenList(
      String sessionId, int start_index, int last_index) async {
    ActionTakenApiCall obj = ActionTakenApiCall(
      sessionId,
    );
    var response = await obj.callActionTakenAPi(start_index, last_index);
    for (Map json in jsonDecode(response.body)) {
      if (json["status"] == null) {
        json["status"] = '';
      }
      if (json["approver_type"] == null) {
        json["approver_type"] = '';
      }
      if (json["approver_name"] == null) {
        json["approver_name"] = '';
      }
      if (json["created_date"] == null) {
        json["created_date"] = '';
      }
      if (json["document_code"] == null) {
        json["document_code"] = '';
      }
      if (json["incident_type"] == null) {
        json["incident_type"] = '';
      }
      if (json["project_name"] == null) {
        json["project_name"] = '';
      }
      if (json["department_name"] == null) {
        json["department_name"] = '';
      }
      if (json["user_name"] == null) {
        json["user_name"] = '';
      }
      if (json["email_id"] == null) {
        json["email_id"] = '';
      }
      if (json["risk_type"] == null) {
        json["risk_type"] = '';
      }
      if (json["incident_category"] == null) {
        json["incident_category"] = '';
      }
      if (json["description"] == null) {
        json["description"] = '';
      }
      if (json["action_taken"] == null) {
        json["action_taken"] = '';
      }
      listProtect.add(CProtect.fromJson(json));
    }
    if (mounted == true) {
      setState(() {
        itemsProtect.addAll(listProtect);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('az');
    return Scaffold(
      key: const ValueKey('actionTaken'),
      body: _isFirstLoadRunning
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(kReSustainabilityRed)))
          : Column(
              children: [
                Expanded(
                    child: Stack(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(
                            top: 30.0, right: 10, left: 10),
                        child: TextField(
                          style: const TextStyle(color: kReSustainabilityRed),
                          cursorColor: kReSustainabilityRed,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(
                                  color: kReSustainabilityRed, width: 0.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
                                  color: Colors.grey[300]!, width: 0.5),
                            ),
                            border: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: kReSustainabilityRed),
                            ),
                            hintText: 'Search..',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: kReSustainabilityRed),
                            suffixIcon: IconButton(
                              onPressed: () async {
                                searchController.clear();
                                FocusManager.instance.primaryFocus?.unfocus();
                                String? sortKey = await showDialog(
                                    useRootNavigator: false,
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) =>
                                        const ActionTakenSortPopup());
                                if (mounted == true) {
                                  setState(() {
                                    if (sortKey == 'Asc') {
                                      itemsProtect.sort((a, b) => a
                                          .document_code
                                          .compareTo(b.document_code));
                                    }
                                    if (sortKey == 'Desc') {
                                      itemsProtect.sort((b, a) => a
                                          .document_code
                                          .compareTo(b.document_code));
                                    }
                                    if (sortKey == 'Status') {
                                      itemsProtect.sort((a, b) =>
                                          a.status.compareTo(b.status));
                                    }

                                    if (sortKey == 'Project') {
                                      itemsProtect.sort((a, b) => a.project_name
                                          .compareTo(b.project_name));
                                    }
                                    if (sortKey == 'Incident Type') {
                                      itemsProtect.sort((a, b) => a
                                          .incident_type
                                          .compareTo(b.incident_type));
                                    }
                                  });
                                }
                              },
                              icon: const Icon(Icons.sort_sharp,
                                  color: kReSustainabilityRed),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 15.0, 20.0, 15.0),
                          ),
                          onChanged: (value) {
                            filterPendingActionsSearchResults(
                                value.toLowerCase());
                          },
                          controller: searchController,
                        )),
                    Padding(
                        padding: const EdgeInsets.only(
                            top: 90.0, bottom: 20.0, left: 10.0, right: 10.0),
                        child: getIActionTakenListView())
                  ],
                )),
                if (_isLoadMoreRunning == true)
                  const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 40),
                      child: Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  kReSustainabilityRed)))),
                if (_hasNextPage == false)
                  Container(
                      padding: const EdgeInsets.only(bottom: 20),
                      color: Colors.white,
                      child: const Center(
                          child: Text("You have fetched all the content")))
              ],
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FloatingActionButton(
          backgroundColor: kReSustainabilityRed,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SubmitIncident()),
            ).then((value) => setState(() {}));
          },
          child: const Icon(
            Icons.add,
            size: 45,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void filterPendingActionsSearchResults(String query) {
    List<CProtect> dummySearchList = [];
    dummySearchList.addAll(itemsProtect);
    if (query.isNotEmpty) {
      List<CProtect> dummyListData = [];
      for (var item in dummySearchList) {
        if (item.document_code.toString().toLowerCase().contains(query) ||
            item.status.toString().toLowerCase().contains(query) ||
            item.project_name.toString().toLowerCase().contains(query) ||
            item.incident_type.toString().toLowerCase().contains(query) ||
            item.department_name.toString().toLowerCase().contains(query) ||
            item.approver_name.toString().toLowerCase().contains(query) ||
            item.description.toString().toLowerCase().contains(query) ||
            item.created_date.toString().toLowerCase().contains(query) ||
            item.user_name.toString().toLowerCase().contains(query)) {
          dummyListData.add(item);
        }
      }
      if (mounted == true) {
        setState(() {
          itemsProtect.clear();
          itemsProtect.addAll(dummyListData);
        });
      }
      return;
    } else {
      if (mounted == true) {
        setState(() {
          itemsProtect.clear();
          itemsProtect.addAll(itemsProtect);
        });
      }
    }
  }

  Widget IRCard(int index, CProtect cProtect) {
    return GestureDetector(
      child: Container(
        key: const ValueKey('actionTakenContainer1'),
        width: double.infinity,
        margin: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          color: const Color(0xffffffff),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 2.0,
              spreadRadius: 1.0,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Text(
                    cProtect.document_code,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: Colors.grey.shade600,
                        fontFamily: "ARIAL"),
                  ),
                  const Spacer(),
                  Container(
                      width: 150.0,
                      height: 38.0,
                      decoration: BoxDecoration(
                          color: colorChange(itemsProtect[index]),
                          // color: Colors.green,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30.0)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12.withOpacity(0.1),
                                blurRadius: 2.0,
                                spreadRadius: 1.0)
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Center(child: statusChange(itemsProtect[index])),
                      )),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                cProtect.project_name.titleCase,
                style: const TextStyle(fontFamily: 'ARIAL', fontSize: 13),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        SizedBox(
                          width: 90.0,
                          child: Text(
                            "Raised On :",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        SizedBox(
                          width: 75.0,
                          child: Text(
                            "Raised by :",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                        ),
                      ]),
                      const SizedBox(
                        height: 7,
                      ),
                      Row(children: [
                        SizedBox(
                          width: 90.0,
                          child: Text(
                            cProtect.created_date,
                            // DateFormat("dd-MM-yyyy  hh:mm a").format(
                            //     DateFormat('dd-MMM-yy  hh:mm')
                            //         .parse(cProtect.created_date, true)
                            //         .toLocal()),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        SizedBox(
                          width: 130,
                          child: Text(
                            cProtect.user_name.titleCase,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                        ),
                      ]),
                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Dash(
                            direction: Axis.horizontal,
                            length: 250,
                            dashLength: 12,
                            dashColor: Colors.grey),
                      ),
                      const Divider(
                        height: 1,
                        color: Colors.black,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 75.0,
                            child: Text(
                              "Incident Type",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontFamily: "ARIAL"),
                            ),
                          ),
                          Text(
                            ":",
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Text(
                            cProtect.incident_type.titleCase,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 75.0,
                            child: Text(
                              "Department",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontFamily: "ARIAL"),
                            ),
                          ),
                          Text(
                            ":",
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          SizedBox(
                            width: 180,
                            child: Text(
                              cProtect.department_name.titleCase,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontFamily: "ARIAL"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 75.0,
                            child: Text(
                              "Reviewer",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontFamily: "ARIAL"),
                            ),
                          ),
                          Text(
                            ":",
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          SizedBox(
                            width: 180,
                            child: Text(
                              cProtect.approver_name.titleCase,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontFamily: "ARIAL"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.only(right: 3.0),
                    child: Dash(
                        direction: Axis.vertical,
                        length: 170,
                        dashLength: 12,
                        dashColor: Colors.grey),
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                          radius: 18,
                          backgroundColor: kReSustainabilityRed,
                          child: Text(
                            cProtect.approver_type.split("IRL")[1],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: kReSustainabilityRed,
                            child: Icon(
                              Icons.remove_red_eye_outlined,
                              size: 30,
                              color: Colors.white,
                            )),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => IncidentFormView(
                                    cProtect: cProtect,
                                  )));
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: kReSustainabilityRed,
                            child: Icon(
                              Icons.history,
                              size: 30,
                              color: Colors.white,
                            )),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => IncidentHistory(
                                    cProtect: cProtect,
                                  )));
                        },
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
      onTap: () {},
    );
  }

  Widget getIActionTakenListView() {
    return itemsProtect.isNotEmpty
        ? ListView.builder(
            controller: _controller,
            itemCount: itemsProtect.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == itemsProtect.length) {
                // return const CupertinoActivityIndicator();
                return const Text('');
              }
              return IRCard(index, itemsProtect[index]);
            })
        : const Center(
            child: Text(
            "Create Incidents To Manage",
            style: TextStyle(color: Colors.black),
          ));
  }

  Color colorChange(CProtect cProtect) {
    if (cProtect.approver_type == "IRL2") {
      return const Color(0xffffcb372);
    }
    if (cProtect.approver_type == "IRL3") {
      return const Color(0xff6B8E23);
    }
    if (cProtect.approver_type == "IRL1") {
      return const Color(0xffE1C16E);
    }
    return Colors.grey;
  }

  Widget statusChange(CProtect cProtect) {
    if (cProtect.approver_type == "IRL1") {
      return const Text(
        "In-Progress",
        style: TextStyle(fontSize: 12, color: Colors.white),
      );
    }
    if (cProtect.approver_type == "IRL2") {
      return const Column(
        children: [
          Text(
            "Action Taken",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          Text(
            "Review In-progress",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      );
    }
    if (cProtect.approver_type == "IRL3") {
      return const Column(
        children: [
          Text(
            "Review Done",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          Text(
            "Closure Pending",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      );
    }
    return const Text(
      "Reviewer not assigned",
      style: TextStyle(fontSize: 12, color: Colors.white),
    );
  }
}