import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resus_test/AppStation/Iris/model/iwm/iwm_disposal_data_model.dart';
import 'package:resus_test/AppStation/Iris/model/iwm/iwm_receipt_data_model.dart';
import 'package:sizer/sizer.dart';

import '../../../Utility/utils/constants.dart';

class IwmSummary extends StatefulWidget {
  const IwmSummary({super.key});

  @override
  State<IwmSummary> createState() => _IwmSummaryState();
}

class _IwmSummaryState extends State<IwmSummary> {

  @override
  Widget build(BuildContext context) {

    NumberFormat formatter = NumberFormat.decimalPatternDigits(
      locale: 'en_us',
      decimalDigits: 2,
    );

    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, right: 20.0, bottom: 20, top: 15.0),
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "IWM Summary ",
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
                          borderRadius: const BorderRadius.all(
                              Radius.circular(15))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Total Receipt",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400)),
                          const SizedBox(height: 15.0),
                          ValueListenableBuilder(
                            valueListenable: iwmReceiptDataListNotifier,
                            builder: (context, List<IwmReceiptDataListResponseModel> receiptDataList, child) {
                              if(receiptDataList.isNotEmpty){
                                return  Text(
                                    "${formatter.format(receiptDataList[0].receiptTotalWasteSum)} MT",
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700));
                              }else{
                                return const Text(
                                    "0.0 MT",
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
                          borderRadius: const BorderRadius.all(
                              Radius.circular(15))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Total Disposal",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400)),
                          const SizedBox(height: 15.0),
                          ValueListenableBuilder(
                            valueListenable: iwmDisposalDataListNotifier,
                            builder: (context, List<IwmDisposalDataListResponseModel> disposalDataList, child) {
                              if(disposalDataList.isNotEmpty){
                                return  Text(
                                    "${formatter.format(disposalDataList[0].disposalTotalWasteSum)} MT",
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700));
                              }else{
                                return const Text(
                                    "0.0 MT",
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
