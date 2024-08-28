import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:resus_test/AppStation/Brainbox/Models/CBrainBox.dart';

import '../../Utility/utils/constants.dart';

class IdeasFormView extends StatefulWidget {
  final CBrainBox cBrainBox;

  const IdeasFormView({super.key, required this.cBrainBox});

  @override
  State<IdeasFormView> createState() => _IdeasFormViewState(cBrainBox);
}

class _IdeasFormViewState extends State<IdeasFormView> {
  CBrainBox m_cBrainBox;

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  _IdeasFormViewState(this.m_cBrainBox);

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
    initializeDateFormatting('az');
    return Material(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kReSustainabilityRed,
          title: const Text(
            'Ideas Form View',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'ARIAL',
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              irmActionCardCard(m_cBrainBox),
              const Padding(
                padding: EdgeInsets.only(left: 20.0, top: 20),
                child: Text(
                  "IDEAS DETAILS",
                  style: TextStyle(
                      fontFamily: "ARIAL",
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(15.0),
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
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 110.0,
                            child: Text(
                              "Theme Type",
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
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            m_cBrainBox.theme_name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
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
                              "Idea",
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
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 150,
                            child: Text(
                              m_cBrainBox.title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontFamily: "ARIAL"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 130.0,
                            child: Text(
                              "Idea Description :",
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
                            m_cBrainBox.description.titleCase,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20.0, top: 20),
                child: Text(
                  "EVALUATOR",
                  style: TextStyle(
                      fontFamily: "ARIAL",
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(15.0),
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
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 40.0,
                            child: Text(
                              "Name",
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
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            m_cBrainBox.approver_name.titleCase,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
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
                            width: 40.0,
                            child: Text(
                              "Email",
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
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            m_cBrainBox.email_id,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget irmActionCardCard(CBrainBox cBrainBox) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(15.0),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Text(
                  m_cBrainBox.idea_no,
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
                        color: colorChange(m_cBrainBox),
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
                      child: Center(child: statusChange(m_cBrainBox)),
                    )),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 90.0,
                  child: Text(
                    "Name",
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
                  width: 10,
                ),
                // Container(
                //   width: 180,
                //   child: Text(m_cBrainBox.user_name.titleCase,
                //     style: TextStyle(
                //         fontWeight: FontWeight.bold,
                //         fontSize: 12,
                //         color: Colors.grey.shade600,
                //         fontFamily: "ARIAL"),
                //   ),
                // ),

                SizedBox(
                  width: 180,
                  child: Text(
                    // cBrainBox.user_name.titleCase,
                    (() {
                      if (m_cBrainBox.is_anonymous == "true" ||
                          cBrainBox.is_anonymous == null) {
                        return "";
                      } else {
                        return m_cBrainBox.user_name.titleCase;
                      }
                    })(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
                  width: 90.0,
                  child: Text(
                    "Project",
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
                  width: 10,
                ),
                SizedBox(
                  width: 180,
                  child: Text(
                    m_cBrainBox.project_name.titleCase,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
                  width: 90.0,
                  child: Text(
                    "Department",
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
                  width: 10,
                ),
                SizedBox(
                  width: 180,
                  child: Text(
                    m_cBrainBox.department_name.titleCase,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
                  width: 90.0,
                  child: Text(
                    "Created Date",
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
                  width: 10,
                ),
                Text(
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
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 90.0,
                  child: Text(
                    "Last Updated",
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
                  width: 10,
                ),
                // Text(
                //   DateFormat("dd-MMM-yyyy  hh:mm").format(
                //       DateFormat('yyyy-MM-dd HH:mm:ss.sss')
                //           .parse(cBrainBox.action_taken_datetime, true)
                //           .toLocal()),
                //   style: TextStyle(
                //       fontWeight: FontWeight.bold,
                //       fontSize: 11,
                //       color: Colors.grey.shade600,
                //       fontFamily: "ARIAL"),
                // ),

                submissionDateField(cBrainBox.action_taken)
              ],
            ),
          ],
        ),
      ),
    );
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
}
