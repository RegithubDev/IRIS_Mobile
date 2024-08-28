import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../../Utility/utils/constants.dart';
import '../model/collection_data_list_model.dart';
import '../model/processing_data_list_model.dart';

class WasteSummary extends StatefulWidget {
  const WasteSummary({super.key});

  @override
  State<WasteSummary> createState() => _WasteSummaryState();
}

class _WasteSummaryState extends State<WasteSummary> {
  NumberFormat formatter = NumberFormat.decimalPatternDigits(
    locale: 'en_us',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: collectionDataListValueNotifier,
      builder: (BuildContext ctx,
          List<CollectionDataListResponseModel> dataList, Widget? child) {
        if (dataList.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(
                left: 10.0, right: 10.0, bottom: 10, top: 15.0),
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: const Text(
                        "Waste Summary",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 117.0,
                              height: 90.0,
                              decoration: BoxDecoration(
                                  color: kSummarySiteSbuColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.4),
                                      spreadRadius: 0.5,
                                      blurRadius: 2,
                                      offset: const Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("Waste Collected",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400)),
                                  const SizedBox(height: 15.0),
                                  ValueListenableBuilder(
                                    valueListenable:
                                        collectionDataListValueNotifier,
                                    builder: (BuildContext ctx,
                                        List<CollectionDataListResponseModel>
                                            dataList,
                                        Widget? child) {
                                      if (dataList.isNotEmpty) {
                                        return Text(
                                            "${formatter.format(dataList[0].qtySum!)} MT",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w700));
                                      } else {
                                        return const Text("0 MT",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w700));
                                      }
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 117.0,
                              height: 90.0,
                              decoration: BoxDecoration(
                                  color: kSummarySiteSbuColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.4),
                                      spreadRadius: 0.5,
                                      blurRadius: 2,
                                      offset: const Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("Waste Processed",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400)),
                                  const SizedBox(height: 15.0),
                                  ValueListenableBuilder(
                                    valueListenable:
                                        processingDataListValueNotifier,
                                    builder: (BuildContext ctx,
                                        List<ProcessingDataListResponseModel>
                                            dataList,
                                        Widget? child) {
                                      if (dataList.isNotEmpty) {
                                        return Text(
                                            "${formatter.format(dataList[0].totalWasteSum!)} MT",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w700));
                                      } else {
                                        return const Text("0 MT",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w700));
                                      }
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
          );
        } else if (dataList.isEmpty) {
          return ValueListenableBuilder(
            valueListenable: processingDataListValueNotifier,
            builder: (BuildContext ctx,
                List<ProcessingDataListResponseModel> dataList, Widget? child) {
              if (dataList.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10, bottom: 10, top: 15.0),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            "Waste Summary",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 117.0,
                                    height: 90.0,
                                    decoration: const BoxDecoration(
                                        color: kSummarySiteSbuColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text("Waste Collected",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w400)),
                                        const SizedBox(height: 10.0),
                                        ValueListenableBuilder(
                                          valueListenable:
                                              collectionDataListValueNotifier,
                                          builder: (BuildContext ctx,
                                              List<CollectionDataListResponseModel>
                                                  dataList,
                                              Widget? child) {
                                            if (dataList.isNotEmpty) {
                                              return Text(
                                                  "${formatter.format(double.tryParse(dataList[0].qtySum!.toString()))} MT",
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w700));
                                            } else {
                                              return const Text("0 MT",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w700));
                                            }
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 117.0,
                                    height: 90.0,
                                    decoration: const BoxDecoration(
                                        color: kSummarySiteSbuColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text("Waste Processed",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w400)),
                                        const SizedBox(height: 10.0),
                                        ValueListenableBuilder(
                                          valueListenable:
                                              processingDataListValueNotifier,
                                          builder: (BuildContext ctx,
                                              List<ProcessingDataListResponseModel>
                                                  dataList,
                                              Widget? child) {
                                            if (dataList.isNotEmpty) {
                                              return Text(
                                                  "${formatter.format(dataList[0].totalWasteSum!)} MT",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w700));
                                            } else {
                                              return const Text("0 MT",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w700));
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                );
              } else {
                return const SizedBox();
              }
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
