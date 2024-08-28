import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';

import '../../Utility/utils/constants.dart';
import 'API Call/ideas_history_api_call.dart';
import 'Models/CBrainBox.dart';
import 'Models/CBrainBoxHistory.dart';
import 'Sort/ideas_history_sort_popup.dart';

class IdeasHistory extends StatefulWidget {
  final CBrainBox cBrainBox;

  const IdeasHistory({super.key, required this.cBrainBox});

  @override
  State<IdeasHistory> createState() => _IdeasHistoryState(cBrainBox);
}

class _IdeasHistoryState extends State<IdeasHistory> {
  final CBrainBox cBrainBox;
  TextEditingController searchController = TextEditingController();

  late List<CBrainBoxHistory> listIdeasHistory = [];
  List<CBrainBoxHistory> itemsIdeasHistory = [];

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  _IdeasHistoryState(this.cBrainBox);

  @override
  void initState() {
    super.initState();
    populateBBHistoryList(cBrainBox.idea_no);
  }

  @override
  void dispose() {
    //subscription.cancel();
    super.dispose();
  }

  void populateBBHistoryList(String ideaNO) async {
    IdeasHistoryApiCall obj = IdeasHistoryApiCall(ideaNO);
    var response = await obj.callIdeasHistoryAPi();
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
      if (json["id"] == null) {
        json["id"] = '';
      }
      listIdeasHistory.add(CBrainBoxHistory.fromJson(json));
    }
    if (mounted == true) {
      setState(() {
        itemsIdeasHistory.addAll(listIdeasHistory);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('az');
    return Scaffold(
      key: const ValueKey('incidentHistory'),
      appBar: AppBar(
        backgroundColor: kReSustainabilityRed,
        title: const Text(
          "Idea Flow History",
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
                              barrierDismissible: false,
                              context: context,
                              useRootNavigator: false,
                              builder: (BuildContext context) =>
                                  const IdeasHistorySortPopup());
                          if (mounted == true) {
                            setState(() {
                              if (sortKey == 'Created Date') {
                                listIdeasHistory.sort((a, b) =>
                                    a.assigned_on.compareTo(b.assigned_on));
                                itemsIdeasHistory.clear();
                                itemsIdeasHistory.addAll(listIdeasHistory);
                              }
                              if (sortKey == 'Reviewer Type') {
                                listIdeasHistory.sort((a, b) =>
                                    a.approver_type.compareTo(b.approver_type));
                                itemsIdeasHistory.clear();
                                itemsIdeasHistory.addAll(listIdeasHistory);
                              }
                              if (sortKey == 'Reviewer Name') {
                                listIdeasHistory.sort((a, b) =>
                                    a.user_name.compareTo(b.user_name));
                                itemsIdeasHistory.clear();
                                itemsIdeasHistory.addAll(listIdeasHistory);
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
                padding: const EdgeInsets.only(left: 150.0, top: 80),
                child: Text(
                  cBrainBox.idea_no,
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
                  child: getIdeasHistoryListView())
            ],
          )),
        ],
      ),
    );
  }

  Widget ideasHistoryCard(int index, CBrainBoxHistory cBrainBoxHistory) {
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
                        // cBrainBoxHistory.assigned_on,

                        DateFormat("dd-MMM-yyyy  hh:mm a").format(
                            DateFormat('dd-MMM-yy  hh:mm')
                                .parse(cBrainBoxHistory.assigned_on, true)
                                .toLocal()),

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
                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     SizedBox(
                  //       width: 110.0,
                  //       child: Text(
                  //         "Action Taken On :",
                  //         style: TextStyle(
                  //             fontWeight: FontWeight.normal,
                  //             fontSize: 12,
                  //             color: Colors.grey.shade600,
                  //             fontFamily: "ARIAL"),
                  //       ),
                  //     ),
                  //     const SizedBox(
                  //       height: 10,
                  //     ),
                  //     Text(
                  //       cIrmHistory.action_taken,
                  //       style: TextStyle(
                  //           fontWeight: FontWeight.bold,
                  //           fontSize: 10,
                  //           color: Colors.grey.shade600,
                  //           fontFamily: "ARIAL"),
                  //     ),
                  //     /*Text(DateFormat("dd-MM-yyyy  hh:mm a").format(
                  //         DateFormat('dd-MMM-yy  hh:mm')
                  //             .parse(cIrmHistory.action_taken.toString(), true)
                  //             .toLocal()),
                  //       style:  TextStyle(
                  //           fontWeight: FontWeight.bold,
                  //           fontSize: 11,
                  //           color: Colors.grey.shade600,fontFamily: "ARIAL"),
                  //     ),*/
                  //   ],
                  // ),
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
                      child:
                          Center(child: iconChange(itemsIdeasHistory[index]))),
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
                        cBrainBoxHistory.approver_type,
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
                          cBrainBoxHistory.user_name.titleCase,
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
                          cBrainBoxHistory.sb_notes.titleCase,
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

  Widget getIdeasHistoryListView() {
    return itemsIdeasHistory.isNotEmpty
        ? ListView.builder(
            itemCount: itemsIdeasHistory.length,
            itemBuilder: (BuildContext context, int index) {
              return ideasHistoryCard(index, itemsIdeasHistory[index]);
            })
        : const Center(
            child: Text(
            "No Ideas History Items",
            style: TextStyle(color: Colors.black),
          ));
  }

  void filterIncidentHistorySearchResults(String query) {
    List<CBrainBoxHistory> dummySearchList = [];
    dummySearchList.addAll(listIdeasHistory);
    if (query.isNotEmpty) {
      List<CBrainBoxHistory> dummyListData = [];
      for (var item in dummySearchList) {
        if (item.assigned_on.toString().toLowerCase().contains(query) ||
            item.action_taken.toString().toLowerCase().contains(query) ||
            item.approver_type.toString().toLowerCase().contains(query) ||
            item.user_name.toString().toLowerCase().contains(query) ||
            item.status.toString().toLowerCase().contains(query) ||
            item.sb_notes.toString().toLowerCase().contains(query)) {
          dummyListData.add(item);
        }
      }
      if (mounted == true) {
        setState(() {
          itemsIdeasHistory.clear();
          itemsIdeasHistory.addAll(dummyListData);
        });
      }
      return;
    } else {
      if (mounted == true) {
        setState(() {
          itemsIdeasHistory.clear();
          itemsIdeasHistory.addAll(listIdeasHistory);
        });
      }
    }
  }

  Icon iconChange(CBrainBoxHistory cBrainBoxHistory) {
    if (cBrainBoxHistory.approver_type == "User") {
      return const Icon(
        Icons.data_saver_off_outlined,
        color: Color(0xffE1C16E),
        size: 28,
      );
    }
    if (cBrainBoxHistory.approver_type == "Evaluator") {
      return const Icon(
        Icons.arrow_upward_outlined,
        color: Colors.green,
        size: 30,
      );
    }
    if (cBrainBoxHistory.approver_type == "Committee") {
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
