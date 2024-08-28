import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:resus_test/AppStation/Brainbox/submit_idea.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:sizer/sizer.dart';

import '../../../Utility/MySharedPreferences.dart';
import '../../../Utility/network_error_dialogbox.dart';
import '../../../Utility/utils/constants.dart';
import '../API Call/pending_ideas_api_call.dart';
import '../Models/CBrainBox.dart';
import '../Sort/pending_ideas_sort_popup.dart';
import '../ideas_form_view.dart';
import '../ideas_history.dart';

class PendingIdeas extends StatefulWidget {
  const PendingIdeas({super.key});

  @override
  State<PendingIdeas> createState() => _PendingIdeasState();
}

class _PendingIdeasState extends State<PendingIdeas> {
  TextEditingController searchController = TextEditingController();

  late List<CBrainBox> listIdeas = [];
  List<CBrainBox> itemsIdeas = [];

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  bool _isFirstLoadRunning = false;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  late ScrollController _controller;

  int startIndex = 0;
  int pageIndex = 10;
  int pageLength = 10;

  @override
  void initState() {
    getConnectivity();
    super.initState();
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
          .getCityStringValue('base_role')
          .then((role) async {
        MySharedPreferences.instance
            .getCityStringValue('JSESSIONID')
            .then((session) async {
          populatePendingIdeasList(session, userid, startIndex, role);
        });
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
      listIdeas.clear();
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
            .getCityStringValue('base_role')
            .then((role) async {
          MySharedPreferences.instance
              .getCityStringValue('JSESSIONID')
              .then((session) async {
            var isConnected = await Future.value(checkInternetConnection())
                .timeout(const Duration(seconds: 2));
            if (!isConnected) {
              // ignore: use_build_context_synchronously
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  useRootNavigator: false,
                  builder: (_) => const NetworkErrorDialog());
              return;
            }
            PendingIdeasApiCall obj = PendingIdeasApiCall(session);
            var response =
                await obj.callPendingIdeasAPi(startIndex, userid, role);
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
              if (json["id"] == null) {
                json["id"] = '';
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
              if (json["description"] == null) {
                json["description"] = '';
              }
              if (json["action_taken"] == null) {
                json["action_taken"] = '';
              }
              if (json["theme_name"] == null) {
                json["theme_name"] = '';
              }
              if (json["title"] == null) {
                json["title"] = '';
              }
              if (json["idea_no"] == null) {
                json["idea_no"] = '';
              }
              if (json["created_date_time"] == null) {
                json["created_date_time"] = '';
              }
              if (json["action_taken_datetime"] == null) {
                json["action_taken_datetime"] = '';
              }
              if (json["is_anonymous"] == null) {
                json["is_anonymous"] = 'false';
              }
              listIdeas.add(CBrainBox.fromJson(json));
            }
            if (listIdeas.isNotEmpty) {
              if (mounted == true) {
                setState(() {
                  itemsIdeas.addAll(listIdeas);
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

  @override
  void dispose() {
    //subscription.cancel();
    super.dispose();
  }

  void populatePendingIdeasList(
      String sessionId, String userId, int startIndex, String role) async {
    PendingIdeasApiCall obj = PendingIdeasApiCall(sessionId);
    var response = await obj.callPendingIdeasAPi(startIndex, userId, role);
    if (response.body == "[]") {
      return;
    }
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
      if (json["id"] == null) {
        json["id"] = '';
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
      if (json["description"] == null) {
        json["description"] = '';
      }
      if (json["action_taken"] == null) {
        json["action_taken"] = '';
      }
      if (json["theme_name"] == null) {
        json["theme_name"] = '';
      }
      if (json["title"] == null) {
        json["title"] = '';
      }
      if (json["idea_no"] == null) {
        json["idea_no"] = '';
      }
      if (json["created_date_time"] == null) {
        json["created_date_time"] = '';
      }
      if (json["action_taken_datetime"] == null) {
        json["action_taken_datetime"] = '';
      }
      if (json["is_anonymous"] == null) {
        json["is_anonymous"] = 'false';
      }
      listIdeas.add(CBrainBox.fromJson(json));
    }
    if (mounted == true) {
      setState(() {
        itemsIdeas.addAll(listIdeas);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('az');
    return Scaffold(
      key: const ValueKey('myIrContainer'),
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
                                    barrierDismissible: false,
                                    context: context,
                                    useRootNavigator: false,
                                    builder: (BuildContext context) =>
                                        const PendingIdeasSortPopup());
                                if (mounted == true) {
                                  setState(() {
                                    if (sortKey == 'Asc') {
                                      itemsIdeas.sort((a, b) =>
                                          a.idea_no.compareTo(b.idea_no));
                                    }
                                    if (sortKey == 'Desc') {
                                      itemsIdeas.sort((b, a) =>
                                          a.idea_no.compareTo(b.idea_no));
                                    }
                                    if (sortKey == 'Status') {
                                      itemsIdeas.sort((a, b) =>
                                          a.status.compareTo(b.status));
                                    }
                                    if (sortKey == 'Project') {
                                      itemsIdeas.sort((a, b) => a.project_name
                                          .compareTo(b.project_name));
                                    }
                                    if (sortKey == 'Theme Type') {
                                      itemsIdeas.sort((a, b) =>
                                          a.theme_name.compareTo(b.theme_name));
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
                            filterIdeasSearchResults(value.toLowerCase());
                          },
                          controller: searchController,
                        )),
                    Padding(
                        padding: const EdgeInsets.only(
                            top: 90.0, bottom: 20.0, left: 10.0, right: 10.0),
                        child: getIdeasListView())
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
              MaterialPageRoute(builder: (context) => const SubmitIdea()),
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

  void filterIdeasSearchResults(String query) {
    List<CBrainBox> dummySearchList = [];
    dummySearchList.addAll(listIdeas);
    if (query.isNotEmpty) {
      List<CBrainBox> dummyListData = [];
      for (var item in dummySearchList) {
        if (item.idea_no.toString().toLowerCase().contains(query) ||
            item.status.toString().toLowerCase().contains(query) ||
            item.project_name.toString().toLowerCase().contains(query) ||
            item.title.toString().toLowerCase().contains(query) ||
            item.department_name.toString().toLowerCase().contains(query) ||
            item.approver_name.toString().toLowerCase().contains(query) ||
            item.description.toString().toLowerCase().contains(query) ||
            item.created_date.toString().toLowerCase().contains(query) ||
            item.theme_name.toString().toLowerCase().contains(query) ||
            item.approver_type.toString().toLowerCase().contains(query) ||
            item.user_name.toString().toLowerCase().contains(query)) {
          dummyListData.add(item);
        }
      }
      if (mounted == true) {
        setState(() {
          itemsIdeas.clear();
          itemsIdeas.addAll(dummyListData);
        });
      }
      return;
    } else {
      if (mounted == true) {
        setState(() {
          itemsIdeas.clear();
          itemsIdeas.addAll(listIdeas);
        });
      }
    }
  }

  Widget ideaCard(int index, CBrainBox cBrainBox) {
    return GestureDetector(
      child: Container(
        key: const ValueKey('myIrContainer1'),
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
                    cBrainBox.idea_no,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: Colors.grey.shade600,
                        fontFamily: "ARIAL"),
                  ),
                  const Spacer(),
                  Container(
                      key: const ValueKey('myIrContainer2'),
                      width: 150.0,
                      height: 38.0,
                      decoration: BoxDecoration(
                          color: colorChange(itemsIdeas[index]),
                          // color: Colors.green,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30.0)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12.withOpacity(0.1),
                                blurRadius: 2.0,
                                spreadRadius: 1.0)
                          ]),
                      child: Center(child: statusChange(itemsIdeas[index]))),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                cBrainBox.project_name.titleCase,
                style: const TextStyle(fontFamily: 'ARIAL', fontSize: 13),
              ),
              const SizedBox(height: 10.0),
              Text(
                cBrainBox.title.titleCase,
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
                            "Submission Date :",
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
                            DateFormat("dd-MMM-yyyy  hh:mm").format(
                                DateFormat('yyyy-MM-dd HH:mm:ss.sss')
                                    .parse(cBrainBox.created_date_time, true)
                                    .toLocal()),
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
                            // cBrainBox.user_name.titleCase,
                            (() {
                              if (cBrainBox.is_anonymous == "true" ||
                                  cBrainBox.is_anonymous == null) {
                                return "";
                              } else {
                                return cBrainBox.user_name.titleCase;
                              }
                            })(),
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
                              "Theme Type",
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
                            cBrainBox.theme_name,
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
                              cBrainBox.department_name.titleCase,
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
                        length: 135,
                        dashLength: 12,
                        dashColor: Colors.grey),
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: kReSustainabilityRed,
                        child: Center(
                            child: _approverTypeField(cBrainBox.approver_type)),
                      ),
                      SizedBox(
                        height: 1.5.h,
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
                              builder: (context) => IdeasFormView(
                                    cBrainBox: cBrainBox,
                                  )));
                        },
                      ),
                      SizedBox(
                        height: 1.5.h,
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
                              builder: (context) => IdeasHistory(
                                    cBrainBox: cBrainBox,
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

  Widget getIdeasListView() {
    return itemsIdeas.isNotEmpty
        ? ListView.builder(
            controller: _controller,
            itemCount: itemsIdeas.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == itemsIdeas.length) {
                // return const CupertinoActivityIndicator();
                return const Text('');
              }
              return ideaCard(index, itemsIdeas[index]);
            })
        : const Center(
            child: Text(
            "Create Ideas To Manage",
            style: TextStyle(color: Colors.black),
          ));
  }

  Color colorChange(CBrainBox cBrainBox) {
    if (cBrainBox.approver_type == "Committee") {
      return const Color(0xff6B8E23);
    }
    if (cBrainBox.approver_type == "Evaluator") {
      return const Color(0xffE1C16E);
    }
    return Colors.grey;
  }

  Widget statusChange(CBrainBox cBrainBox) {
    if (cBrainBox.approver_type == "Evaluator") {
      return const Text(
        "Evaluation In progress",
        style: TextStyle(fontSize: 12, color: Colors.white),
      );
    }
    if (cBrainBox.approver_type == "Committee") {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Committee Evaluation",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          Text(
            "In progress",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      );
    }
    // if (cBrainBox.approver_type == "IRL3") {
    //   return Text(
    //     "Approved",
    //     style: TextStyle(fontSize: 12, color: Colors.white),
    //   );
    // }
    return const Text(
      "No Reviewer Assigned",
      style: TextStyle(fontSize: 12, color: Colors.white),
    );
  }

  Widget submissionDateField(value) {
    return Text(
      (() {
        if (value == "") {
          return "";
        } else {
          return value.split("| <br> |")[0] + value.split("| <br> |")[1];
          // return concatString(value);
        }
      })(),
      style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 11,
          fontWeight: FontWeight.bold),
    );
  }

  Widget _approverTypeField(value) {
    return Center(
      child: Text(
        (() {
          if (value == "") {
            return "";
          } else {
            return value[0];
          }
        })(),
        style: const TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}
