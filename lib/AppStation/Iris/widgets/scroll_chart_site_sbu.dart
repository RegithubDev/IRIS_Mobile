import 'package:carousel_slider/carousel_slider.dart';
import 'package:d_chart/commons/config_render.dart';
import 'package:d_chart/commons/data_model.dart';
import 'package:d_chart/commons/decorator.dart';
import 'package:d_chart/commons/enums.dart';
import 'package:d_chart/commons/style.dart';
import 'package:d_chart/ordinal/bar.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../Utility/utils/constants.dart';
import '../model/collection_data_list_model.dart';
import '../model/processing_data_list_model.dart';
import '../model/recyclable_data_list_model.dart';

class ScrollChart extends StatefulWidget {
  const ScrollChart({super.key});

  @override
  State<ScrollChart> createState() => _ScrollChartState();
}

class _ScrollChartState extends State<ScrollChart> {

  final List chartDataSiteHead = [
    {"id": 1, "data_type": 'collection'},
    {"id": 2, "data_type": 'processing'},
    {"id": 3, "data_type": 'recyclable'}
  ];

  final CarouselController siteSbuCarouselController = CarouselController();

  int scrollIndex = 0;
  int recycleIndex = 0;

  List<OrdinalData> incinerationList = [];
  List<OrdinalData> autoclaveList = [];
  List<OrdinalData> recyclableList = [];
  List<OrdinalData> processingList = [];
  List<OrdinalData> collectionList = [];

  List<OrdinalData> bagList = [];
  List<OrdinalData> glassList = [];
  List<OrdinalData> cardBoardList = [];
  List<OrdinalData> plasticList = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.41,
            decoration:BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(
                      0, 1), // changes position of shadow
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: CarouselSlider(
                items: chartDataSiteHead
                    .map(
                      (item) => carouselContentSiteHead(
                    item['data_type'],
                  ),
                )
                    .toList(),
                carouselController: siteSbuCarouselController,
                options: CarouselOptions(
                  height:MediaQuery.of(context).size.height * 0.38,
                  aspectRatio: 16 / 9,
                  scrollPhysics: const BouncingScrollPhysics(),
                  enableInfiniteScroll: true,
                  autoPlay: false,
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    setState(() {
                      scrollIndex = index;
                      debugPrint(scrollIndex.toString());
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: chartDataSiteHead.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => siteSbuCarouselController.animateToPage(entry.key),
              child: Container(
                width: scrollIndex == entry.key ? 7 : 7,
                height: 1.h,
                margin: EdgeInsets.symmetric(
                  horizontal: 2.w,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: scrollIndex == entry.key
                        ? kReSustainabilityRed
                        : kGreyTitleColor),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget carouselContentSiteHead(String datatype) {
    if (datatype == "collection") {
      return ValueListenableBuilder(
          valueListenable: collectionDataListValueNotifier,
          builder: (BuildContext context,
              List<CollectionDataListResponseModel> collectionDataList,
              Widget? child) {
            if (collectionDataList.isNotEmpty) {
              collectionDataList.sort(
                      (b, a) => a.collectionDate!.compareTo(b.collectionDate!));
              collectionList.clear();
              for (CollectionDataListResponseModel data in collectionDataList) {
                if(collectionList.length < 5){
                  collectionList.add(OrdinalData(
                      domain: data.collectionDate!.split("-")[2],
                      measure: num.parse(data.collectionQty!),
                      color: kReSustainabilityRed));
                }}
              return Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.38,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SizedBox(
                            height: 30.0,
                            child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Collection Trend",
                                      style: TextStyle(
                                          fontSize: 12.0, color: kColorBlack)),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: kReSustainabilityRed,
                                        width:
                                        1, // Adjust the border width as needed
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Text("Weight in MT",
                                          style: TextStyle(
                                              fontSize: 11.0,
                                              color: kColorBlack)),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: DChartBarO(
                              barLabelValue: (group, ordinalData, index) {
                                return ordinalData.measure.round().toString();
                              },
                              outsideBarLabelStyle:
                                  (group, ordinalData, index) {
                                return const LabelStyle(
                                  fontSize: 8,
                                  color: kColorBlack,
                                );
                              },
                              barLabelDecorator: BarLabelDecorator(
                                  barLabelPosition: BarLabelPosition.outside),
                              configRenderBar: ConfigRenderBar(
                                barGroupInnerPaddingPx: 2,
                                barGroupingType: BarGroupingType.grouped,
                                fillPattern: FillPattern.solid,
                                maxBarWidthPx: 25,
                                radius: 0,
                                stackedBarPaddingPx: 1,
                                strokeWidthPx: 0,
                              ),
                              groupList: [
                                OrdinalGroup(
                                  id: '1',
                                  chartType: ChartType.bar,
                                  color: kChartBarColor,
                                  data: collectionList,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Text("Date",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.0, color: kColorBlack))
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Center(
                child: Text("No Record Available"),
              );
            }
          });
    }
    if (datatype == "processing") {
      return ValueListenableBuilder(
          valueListenable: processingDataListValueNotifier,
          builder: (BuildContext context,
              List<ProcessingDataListResponseModel> processingDataList,
              Widget? child) {
            if (processingDataList.isNotEmpty) {
              processingDataList.sort((b, a) => a.processingDate!.compareTo(b
                  .processingDate!)); // value is the value of the ValueNotifier
              processingList.clear();
              for (ProcessingDataListResponseModel data in processingDataList) {
                if(processingList.length < 5){
                  processingList.add(OrdinalData(
                      domain: data.processingDate!.split("-")[2],
                      measure: num.parse(data.totalWeightQty!),
                      color: kColorRed));
                }}
              return Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.38,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SizedBox(
                            height: 30.0,
                            child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Processing Trend",
                                      style: TextStyle(
                                          fontSize: 12.0, color: kColorBlack)),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: kReSustainabilityRed,
                                        width:
                                        1, // Adjust the border width as needed
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Text("Weight in MT",
                                          style: TextStyle(
                                              fontSize: 11.0,
                                              color: kColorBlack)),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: DChartBarO(
                              barLabelValue: (group, ordinalData, index) {
                                return ordinalData.measure.round().toString();
                              },
                              outsideBarLabelStyle:
                                  (group, ordinalData, index) {
                                return const LabelStyle(
                                  fontSize: 8,
                                  color: kColorBlack,
                                );
                              },
                              barLabelDecorator: BarLabelDecorator(
                                  barLabelPosition: BarLabelPosition.outside),
                              configRenderBar: ConfigRenderBar(
                                barGroupInnerPaddingPx: 2,
                                barGroupingType: BarGroupingType.grouped,
                                fillPattern: FillPattern.solid,
                                maxBarWidthPx: 25,
                                radius: 0,
                                stackedBarPaddingPx: 1,
                                strokeWidthPx: 0,
                              ),
                              groupList: [
                                OrdinalGroup(
                                  id: '1',
                                  chartType: ChartType.bar,
                                  color: kChartBarColor,
                                  data: processingList,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Text("Date",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.0, color: kColorBlack))
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Center(
                child: Text("No Record Available"),
              );
            }
          });
    }
    if (datatype == "recyclable") {
      return ValueListenableBuilder(
        valueListenable: recyclableDataListValueNotifier,
        builder: (BuildContext context,
            List<RecyclableDataListResponseModel> recyclableDataList,
            Widget? child) {
          if (recyclableDataList.isNotEmpty) {
            recyclableDataList.sort((b, a) => a.recyclableDate!.compareTo(
                b.recyclableDate!)); // value is the value of the ValueNotifier
            recyclableList.clear();
            for (RecyclableDataListResponseModel data in recyclableDataList) {
              if(recyclableList.length <= 4){
                recyclableList.add(OrdinalData(
                    domain: data.recyclableDate!.split("-")[2],
                    measure: num.parse(data.recyclableQty!),
                    color: kReSustainabilityRed));
              }
            }
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.38,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        height: 30.0,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Recyclables Trend",
                                  style: TextStyle(
                                      fontSize: 12.0, color: kColorBlack)),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: kReSustainabilityRed,
                                    width:
                                    1, // Adjust the border width as needed
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text("Weight in MT",
                                      style: TextStyle(
                                          fontSize: 11.0, color: kColorBlack)),
                                ),
                              ),
                            ]),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25.0,),
                        child: DChartBarO(
                          barLabelValue: (group, ordinalData, index) {
                            return ordinalData.measure.round().toString();
                          },
                          outsideBarLabelStyle: (group, ordinalData, index) {
                            return const LabelStyle(
                              fontSize: 8,
                              color: kColorBlack,
                            );
                          },
                          barLabelDecorator: BarLabelDecorator(
                              barLabelPosition: BarLabelPosition.outside),
                          configRenderBar: ConfigRenderBar(
                            barGroupInnerPaddingPx: 2,
                            barGroupingType: BarGroupingType.grouped,
                            fillPattern: FillPattern.solid,
                            maxBarWidthPx: 25,
                            radius: 0,
                            stackedBarPaddingPx: 1,
                            strokeWidthPx: 0,
                          ),
                          groupList: [
                            OrdinalGroup(
                              id: '1',
                              chartType: ChartType.bar,
                              color: kChartBarColor,
                              data: recyclableList,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Text("Date",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.0, color: kColorBlack))
                  ],
                ),
              ),
            );
          } else {
            return const Center(
              child: Text("No Record Available"),
            );
          }
        },
      );
    } else {
      return Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 3,),
            const Center(
              child: Text("No Result Available",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14.0,
                      color: kGreyTitleColor,
                      fontWeight: FontWeight.w600)),
            ),
          ]
      );
    }
  }
}
