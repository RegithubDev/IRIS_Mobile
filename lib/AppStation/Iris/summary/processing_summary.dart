import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../Utility/utils/constants.dart';
import '../model/collection_data_list_model.dart';
import '../msw_operaton_head_screens/data_models/msw_process_data_list_model.dart';

class ProcessingSummary extends StatelessWidget {
  final double wasteCollected;
  final double wasteProcessed;
  const ProcessingSummary(
      {super.key, required this.wasteCollected, required this.wasteProcessed});

  @override
  Widget build(BuildContext context) {
    NumberFormat formatter = NumberFormat.decimalPatternDigits(
      locale: 'en_us',
      decimalDigits: 2,
    );

    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10, top: 15.0),
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "MSW Summary ",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      width: 117.0,
                      height: 90.0,
                      decoration: BoxDecoration(
                          color: kSummary1,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 0.5,
                              blurRadius: 2,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15))),
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
                            valueListenable: mswCollectionDataListValueNotifier,
                            builder: (context,
                                List<CollectionDataListResponseModel>
                                    collectionDataList,
                                child) {
                              if (collectionDataList.isNotEmpty) {
                                return Text(
                                    "${formatter.format(collectionDataList[0].qtySum)} MT",
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700));
                              } else {
                                return const Text("0.0 MT",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    child: Container(
                      width: 117.0,
                      height: 90.0,
                      decoration: BoxDecoration(
                          color: kSummary1,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 0.5,
                              blurRadius: 2,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Waste processed",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400)),
                          const SizedBox(height: 15.0),
                          ValueListenableBuilder(
                            valueListenable: mswProcessingDataListValueNotifier,
                            builder: (context,
                                List<MswProcessDataListResponseModel>
                                    processingDataList,
                                child) {
                              if (processingDataList.isNotEmpty) {
                                return Text(
                                    "${formatter.format(processingDataList[0].qtySum)} MT",
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700));
                              } else {
                                return const Text("0.0 MT",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
