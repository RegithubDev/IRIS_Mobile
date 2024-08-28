import 'package:d_chart/commons/config_render.dart';
import 'package:d_chart/commons/data_model.dart';
import 'package:d_chart/ordinal/pie.dart';
import 'package:flutter/material.dart';
import 'package:resus_test/AppStation/Iris/model/collection_data_list_model.dart';
import 'package:resus_test/AppStation/Iris/model/processing_data_list_model.dart';
import 'package:resus_test/AppStation/Iris/model/recyclable_data_list_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../Utility/utils/constants.dart';

class BmwPieChart extends StatefulWidget {
  final double totalQuantity;
  final double totalIncineration;
  final double totalAutoclave;
  final double totalRecyclable;

  const BmwPieChart({
    super.key,
    required this.totalQuantity,
    required this.totalIncineration,
    required this.totalAutoclave,
    required this.totalRecyclable,
  });

  @override
  State<BmwPieChart> createState() => _BmwPieChartState();
}

class _BmwPieChartState extends State<BmwPieChart> {
  List<OrdinalData> dataList = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          height: MediaQuery.of(context).size.height * 0.40,
          child: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.data == "") {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: AspectRatio(
                        aspectRatio: 13 / 9,
                        child: Stack(
                          children: [
                            DChartPieO(
                              data: dataList,
                              configRenderPie: const ConfigRenderPie(
                                arcWidth: 30,
                              ),
                            ),
                            const Positioned(
                              child: Center(
                                child: Text(
                                  "BMW Trends",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 5.0, left: 5.0, bottom: 10.0, top: 10.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipOval(
                                child: Container(
                                  height: 12,
                                  width: 12,
                                  color: kGreenDotColor,
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable:
                                    collectionDataListValueNotifier,
                                builder: (context,
                                    List<CollectionDataListResponseModel>
                                        collectionDataList,
                                    child) {
                                  if (collectionDataList.isNotEmpty) {
                                    return Text(
                                        "Total Quantity - ${collectionDataList[0].qtySum} MT",
                                        style: const TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black));
                                  } else {
                                    return const Text("Total Quantity - 0.0 MT",
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black));
                                  }
                                },
                              ),
                              const SizedBox(
                                width: 4.0,
                              ),
                              ClipOval(
                                child: Container(
                                  height: 12,
                                  width: 12,
                                  color: kOrangeDotColor,
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable:
                                    processingDataListValueNotifier,
                                builder: (context,
                                    List<ProcessingDataListResponseModel>
                                        processingDataList,
                                    child) {
                                  if (processingDataList.isNotEmpty) {
                                    return Text(
                                        "Total Incineration - ${processingDataList[0].totalIncinerationSum} MT",
                                        style: const TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black));
                                  } else {
                                    return const Text(
                                        "Total Incineration - 0.0 MT",
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black));
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipOval(
                                child: Container(
                                  height: 12,
                                  width: 12,
                                  color: kVioletDotColor,
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable:
                                    processingDataListValueNotifier,
                                builder: (context,
                                    List<ProcessingDataListResponseModel>
                                        processingDataList,
                                    child) {
                                  if (processingDataList.isNotEmpty) {
                                    return Text(
                                        "Total AutoClave - ${processingDataList[0].totalAutoclaveSum} MT",
                                        style: const TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black));
                                  } else {
                                    return const Text(
                                        "Total AutoClave - 0.0 MT",
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black));
                                  }
                                },
                              ),
                              const SizedBox(
                                width: 4.0,
                              ),
                              ClipOval(
                                child: Container(
                                  height: 12,
                                  width: 12,
                                  color: kYellowDotColor,
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable:
                                    recyclableDataListValueNotifier,
                                builder: (context,
                                    List<RecyclableDataListResponseModel>
                                        recyclableDataList,
                                    child) {
                                  if (recyclableDataList.isNotEmpty) {
                                    return Text(
                                        "Total Recyclables - ${recyclableDataList[0].totalRecyclableSum} MT",
                                        style: const TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black));
                                  } else {
                                    return const Text(
                                        "Total Recyclables - 0.0 MT",
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black));
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox();
              }
            },
          )),
    );
  }

  Future<String> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
      dataList = [
        OrdinalData(
            domain: 'Total Quantity',
            measure: prefs.getDouble("qtyCollection")!,
            color: kGreenDotColor),
        OrdinalData(
            domain: 'Total Incineration',
            measure: prefs.getDouble("qtyIncierationSum")!,
            color: kOrangeDotColor),
        OrdinalData(
            domain: 'Total AutoClave',
            measure: prefs.getDouble("qtyAutoclaveSum")!,
            color: kVioletDotColor),
        OrdinalData(
            domain: 'Total Recyclables',
            measure: prefs.getDouble("qtyRecyclable")!,
            color: kYellowDotColor),
      ];
  
    return "";
  }
}
