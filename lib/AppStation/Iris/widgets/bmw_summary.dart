import 'package:flutter/material.dart';
import '../../../Utility/utils/constants.dart';
import 'package:intl/intl.dart';
import '../model/collection_data_list_model.dart';
import '../model/processing_data_list_model.dart';

class BmwSummary extends StatefulWidget {
  const BmwSummary({super.key});

  @override
  State<BmwSummary> createState() => _BmwSummaryState();
}

class _BmwSummaryState extends State<BmwSummary> {
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
                left: 20.0, right: 20, bottom: 10, top: 10.0),
            child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 10.0),
                    const Text(
                      "BMW Summary",
                      style: TextStyle(fontWeight: FontWeight.w600),
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
                              height: 80.0,
                              decoration: BoxDecoration(
                                  color: kSummarySiteSbuColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.6),
                                      spreadRadius: 0.5,
                                      blurRadius: 2,
                                      offset: const Offset(
                                          0, 4), // changes position of shadow
                                    ),
                                  ],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("Quantity",
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
                                            "${formatter.format(double.parse(dataList[0].qtySum!.toString()))} MT",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600));
                                      } else {
                                        return const Text("0 MT",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600));
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
                              height: 80.0,
                              decoration: BoxDecoration(
                                  color: kSummarySiteSbuColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.6),
                                      spreadRadius: 0.5,
                                      blurRadius: 2,
                                      offset: const Offset(
                                          0, 4), // changes position of shadow
                                    ),
                                  ],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("Total \nWaste",
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
                                                fontWeight: FontWeight.w600));
                                      } else {
                                        return const Text("0 MT",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600));
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
                              height: 80.0,
                              decoration: BoxDecoration(
                                  color: kSummarySiteSbuColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.6),
                                      spreadRadius: 0.5,
                                      blurRadius: 2,
                                      offset: const Offset(
                                          0, 4), // changes position of shadow
                                    ),
                                  ],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("Total \nIncineration",
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
                                              "${formatter.format(dataList[0].totalIncinerationSum!)} MT",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600));
                                        } else {
                                          return const Text("0 MT",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600));
                                        }
                                      })
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
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
                      left: 10.0, right: 10, bottom: 10, top: 10.0),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(
                                0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 10.0),
                          const Text(
                            "BMW Summary",
                            style: TextStyle(fontWeight: FontWeight.w600),
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
                                    height: 80.0,
                                    decoration: BoxDecoration(
                                        color: kSummarySiteSbuColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.6),
                                            spreadRadius: 0.5,
                                            blurRadius: 2,
                                            offset: const Offset(0,
                                                4), // changes position of shadow
                                          ),
                                        ],
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text("Quantity",
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
                                                  "${formatter.format(double.parse(dataList[0].qtySum!.toString()))} MT",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w600));
                                            } else {
                                              return const Text("0 MT",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w600));
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
                                    height: 80.0,
                                    decoration: BoxDecoration(
                                        color: kSummarySiteSbuColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.6),
                                            spreadRadius: 0.5,
                                            blurRadius: 2,
                                            offset: const Offset(0,
                                                4), // changes position of shadow
                                          ),
                                        ],
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text("Total \nWaste",
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
                                                      fontWeight:
                                                          FontWeight.w600));
                                            } else {
                                              return const Text("0 MT",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w600));
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
                                    height: 80.0,
                                    decoration: BoxDecoration(
                                        color: kSummarySiteSbuColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.6),
                                            spreadRadius: 0.5,
                                            blurRadius: 2,
                                            offset: const Offset(0,
                                                4), // changes position of shadow
                                          ),
                                        ],
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text("Total \nIncineration",
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
                                                    "${formatter.format(dataList[0].totalIncinerationSum!)} MT",
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.w600));
                                              } else {
                                                return const Text("0 MT",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.w600));
                                              }
                                            })
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
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
