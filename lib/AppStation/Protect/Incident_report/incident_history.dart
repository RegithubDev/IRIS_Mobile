import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recase/recase.dart';
import 'package:resus_test/Utility/utils/constants.dart';

import '../../../Utility/api_Url.dart';
import '../api_call/incidentHistoryApiCall.dart';
import '../models/CIrmHistory.dart';
import '../models/CProtect.dart';
import '../sort/incident_history_sort_popup.dart';

class IncidentHistory extends StatefulWidget {
  final CProtect cProtect;

  const IncidentHistory({super.key, required this.cProtect});

  @override
  State<IncidentHistory> createState() => _IncidentHistoryState(cProtect);
}

class _IncidentHistoryState extends State<IncidentHistory> {
  CProtect m_cProtect;
  TextEditingController searchController = TextEditingController();

  late List<CIrmHistory> listIrmHistory = [];
  List<CIrmHistory> itemsIrmHistory = [];

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  _IncidentHistoryState(this.m_cProtect);

  @override
  void initState() {
    super.initState();
    populateActionTakenList(m_cProtect.document_code);
  }

  @override
  void dispose() {
    //subscription.cancel();
    super.dispose();
  }

  void populateActionTakenList(String documentCode) async {
    IncidentHistoryApiCall obj = IncidentHistoryApiCall(documentCode);
    var response = await obj.callIncidentHistoryAPi();
    for (Map json in json.decode(response.body)) {
      if (json["status"] == null) {
        json["status"] = '';
      }
      if (json["approver_type"] == null) {
        json["approver_type"] = '';
      }
      if (json["user_name"] == null) {
        json["user_name"] = '';
      }
      if (json["assigned_on"] == null) {
        json["assigned_on"] = '';
      }
      if (json["action_taken"] == null) {
        json["action_taken"] = '';
      }
      if (json["sb_notes"] == null) {
        json["sb_notes"] = '';
      }
      if (json["document_code"] == null) {
        json["document_code"] = '';
      }
      listIrmHistory.add(CIrmHistory.fromJson(json));
    }
    if (mounted == true) {
      setState(() {
        itemsIrmHistory.addAll(listIrmHistory);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('incidentHistory'),
      appBar: AppBar(
        backgroundColor: kReSustainabilityRed,
        title: const Text(
          "Incident History",
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'ARIAL',
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
              child: Stack(
            children: [
              Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, right: 10, left: 10),
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
                        borderSide:
                            BorderSide(color: Colors.grey[300]!, width: 0.5),
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: kReSustainabilityRed),
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
                                  const IncidentHistorySortPopup());
                          if (mounted == true) {
                            setState(() {
                              if (sortKey == 'Assigned Date') {
                                listIrmHistory.sort((a, b) =>
                                    b.assigned_on.compareTo(a.assigned_on));
                                itemsIrmHistory.clear();
                                itemsIrmHistory.addAll(listIrmHistory);
                              }
                              if (sortKey == 'Action Taken On') {
                                listIrmHistory.sort((a, b) =>
                                    b.action_taken.compareTo(a.action_taken));
                                itemsIrmHistory.clear();
                                itemsIrmHistory.addAll(listIrmHistory);
                              }

                              if (sortKey == 'Reviewer Type') {
                                listIrmHistory.sort((a, b) =>
                                    a.approver_type.compareTo(b.approver_type));
                                itemsIrmHistory.clear();
                                itemsIrmHistory.addAll(listIrmHistory);
                              }
                              if (sortKey == 'Reviewer Name') {
                                listIrmHistory.sort((a, b) =>
                                    a.user_name.compareTo(b.user_name));
                                itemsIrmHistory.clear();
                                itemsIrmHistory.addAll(listIrmHistory);
                              }
                            });
                          }
                        },
                        icon: const Icon(Icons.sort_sharp,
                            color: kReSustainabilityRed),
                      ),
                      contentPadding:
                          const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    ),
                    onChanged: (value) {
                      filterIncidentHistorySearchResults(value.toLowerCase());
                    },
                    controller: searchController,
                  )),
              Padding(
                padding: const EdgeInsets.only(left: 120.0, top: 80),
                child: Text(
                  m_cProtect.document_code,
                  style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'ARIAL',
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(
                      top: 120.0, bottom: 20.0, left: 10.0, right: 10.0),
                  child: getIncidentHistoryListView())
            ],
          )),
        ],
      ),
    );
  }

  Widget IrmHistoryCard(int index, CIrmHistory cIrmHistory) {
    return GestureDetector(
      child: Container(
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
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120.0,
                        child: Text(
                          "Created Date :",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontFamily: "ARIAL"),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        // DateFormat("dd-MM-yyyy  hh:mm a").format(
                        //     DateFormat('dd-MMM-yy  hh:mm')
                        //         .parse(cIrmHistory.assigned_on.toString(), true)
                        //         .toLocal()),
                        cIrmHistory.assigned_on,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            fontFamily: "ARIAL"),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  const Spacer(),
                  Container(
                      width: 45.0,
                      height: 45.0,
                      decoration: BoxDecoration(
                          // color: colorChange(itemsIrmHistory[index]),
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30.0)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12.withOpacity(0.1),
                                blurRadius: 2.0,
                                spreadRadius: 1.0)
                          ]),
                      child: Center(child: iconChange(itemsIrmHistory[index]))),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 110.0,
                        child: Text(
                          "Reviewer Type",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontFamily: "ARIAL"),
                        ),
                      ),
                      Text(
                        ":",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontFamily: "ARIAL"),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Text(
                        cIrmHistory.approver_type,
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
                        width: 110.0,
                        child: Text(
                          "Reviewer Name",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontFamily: "ARIAL"),
                        ),
                      ),
                      Text(
                        ":",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontFamily: "ARIAL"),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      SizedBox(
                        width: 160,
                        child: Text(
                          cIrmHistory.user_name.titleCase,
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
                        width: 110.0,
                        child: Text(
                          "Send Back Notes",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontFamily: "ARIAL"),
                        ),
                      ),
                      Text(
                        ":",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontFamily: "ARIAL"),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      SizedBox(
                        width: 160,
                        child: Text(
                          cIrmHistory.sb_notes.titleCase,
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
              )
            ],
          ),
        ),
      ),
      onTap: () {},
    );
  }

  Widget getIncidentHistoryListView() {
    return itemsIrmHistory.isNotEmpty
        ? ListView.builder(
            itemCount: itemsIrmHistory.length,
            itemBuilder: (BuildContext context, int index) {
              return IrmHistoryCard(index, itemsIrmHistory[index]);
            })
        : const Center(
            child: Text(
            "No Inciednt History Items",
            style: TextStyle(color: Colors.black),
          ));
  }

  void filterIncidentHistorySearchResults(String query) {
    List<CIrmHistory> dummySearchList = [];
    dummySearchList.addAll(listIrmHistory);
    if (query.isNotEmpty) {
      List<CIrmHistory> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item.assigned_on.toString().toLowerCase().contains(query) ||
            item.action_taken.toString().toLowerCase().contains(query) ||
            item.approver_type.toString().toLowerCase().contains(query) ||
            item.user_name.toString().toLowerCase().contains(query) ||
            item.status.toString().toLowerCase().contains(query) ||
            item.sb_notes.toString().toLowerCase().contains(query)) {
          dummyListData.add(item);
        }
      });
      if (mounted == true) {
        setState(() {
          itemsIrmHistory.clear();
          itemsIrmHistory.addAll(dummyListData);
        });
      }
      return;
    } else {
      if (mounted == true) {
        setState(() {
          itemsIrmHistory.clear();
          itemsIrmHistory.addAll(listIrmHistory);
        });
      }
    }
  }

  Color colorChange(CIrmHistory cIrmHistory) {
    if (cIrmHistory.status == "Reviewed") {
      return const Color(0xff50C878);
    }
    if (cIrmHistory.status == "In Progress") {
      return const Color(0xffE1C16E);
    }
    return Colors.grey.shade400;
  }

  Icon iconChange(CIrmHistory cIrmHistory) {
    if (cIrmHistory.approver_type == "IRL1") {
      return const Icon(
        Icons.data_saver_off_outlined,
        color: Color(0xffE1C16E),
        size: 28,
      );
    }
    if (cIrmHistory.approver_type == "IRL2") {
      return const Icon(
        Icons.arrow_upward_outlined,
        color: Colors.green,
        size: 30,
      );
    }
    if (cIrmHistory.approver_type == "IRL3") {
      return const Icon(
        Icons.fiber_manual_record,
        color: Colors.green,
        size: 30,
      );
    }
    return Icon(
      Icons.arrow_upward_outlined,
      color: Colors.grey.shade600,
      size: 30,
    );
  }
}

Future<String> getIrmHistoryListAPICall(http.Client http) async {
  var response = await http.post(Uri.parse(GET_IRM_HISTORY_LIST),
      headers: {
        "Content-Type": 'application/json; charset=utf-8',
      },
      body: json.encode({"document_code": "IRM_2302_507"}));
  if (response.statusCode == 200) {
    return jsonDecode(response.body)["user_name"];
  } else {
    return 'Failed to fetch Irm History response';
  }
}
