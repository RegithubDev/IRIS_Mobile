import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:d_chart/commons/config_render.dart';
import 'package:d_chart/commons/data_model.dart';
import 'package:d_chart/commons/decorator.dart';
import 'package:d_chart/commons/enums.dart';
import 'package:d_chart/commons/style.dart';
import 'package:d_chart/ordinal/bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resus_test/AppStation/Iris/api/get_msw_wte_data_list_api.dart';
import 'package:resus_test/AppStation/Iris/form/msw_wte_form.dart';
import 'package:resus_test/AppStation/Iris/model/msw_wte_data_list_model.dart';
import 'package:resus_test/AppStation/Iris/summary/ash_summary.dart';
import 'package:resus_test/AppStation/Iris/summary/generationSummary.dart';
import 'package:resus_test/AppStation/Iris/summary/rdf_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../../Utility/MySharedPreferences.dart';
import '../../../Utility/internetCheck.dart';
import '../../../Utility/utils/constants.dart';
import '../model/site_data_list_model.dart';

class WteScreen extends StatefulWidget {
  final String selectSBU;
  final String roles;
  const WteScreen({super.key, required this.selectSBU, required this.roles});

  @override
  State<WteScreen> createState() => _WteScreenState();
}

class _WteScreenState extends State<WteScreen>
    with SingleTickerProviderStateMixin {
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  late TextEditingController dateInputController = TextEditingController();
  late TabController tabController, _homeTabController;

  int currentIndex = 0;
  int scrollIndex = 0;
  int recycleIndex = 0;
  bool isDateSelect = false;

  late MswWteDataListRequestModel _mswWteDataListRequestModel;

  String selectedSBU = "";
  String _selectedSite = "";
  String _siteID = "";
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 100)),
    end: DateTime.now(),
  );

  late DateTimeRange? newDateRange;

  List<OrdinalData> rdfReceiptList = [];
  List<OrdinalData> rdfCombustedList = [];

  List<OrdinalData> steamGenerationList = [];
  List<OrdinalData> powerGenerationList = [];
  List<OrdinalData> powerExportList = [];
  List<OrdinalData> powerGenerationCapacityList = [];
  List<OrdinalData> auxillaryConsumptionList = [];
  List<OrdinalData> plantLoadFactorList = [];

  List<OrdinalData> bottomAshList = [];
  List<OrdinalData> flyAshList = [];
  List<OrdinalData> totalAshList = [];

  final List ashDataList = [
    {"id": 1, "data_type": 'bottomAsh'},
    {"id": 2, "data_type": 'flyAsh'},
    {"id": 3, "data_type": 'totalAsh'}
  ];

  final List generationDataList = [
    {"id": 1, "data_type": 'steamGen'},
    {"id": 2, "data_type": 'powerGen'},
    {"id": 3, "data_type": 'powerExport'},
    {"id": 4, "data_type": 'powerGenCap'},
    {"id": 5, "data_type": 'auxConsumption'},
    {"id": 6, "data_type": 'plantLoadFactor'}
  ];

  final List rdfDataList = [
    {"id": 1, "data_type": 'rdfReceipt'},
    {"id": 2, "data_type": 'rdfCombusted'}
  ];

  String receipt = "";
  String combusted = "";

  final CarouselController carouselController = CarouselController();

  String formatNumber(double number) {
    if (number == 0 || number < 1) {
      return number.toStringAsFixed(2);
    }
    final formatter = NumberFormat('#,###.00');
    String formattedNumber = formatter.format(number);
    return formattedNumber;
  }

  @override
  void initState() {
    _homeTabController = TabController(vsync: this, length: 3);
    getConnectivity();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: wteHomeScreen(context),
      bottomNavigationBar: widget.roles.contains("WTE")
          ? Container(
              height: Platform.isIOS ? 85 : 70,
              color: kReSustainabilityRed,
              child: Center(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MswWteForm(),
                      )),
                      child: SizedBox(
                          height: 60,
                          width: 60,
                          child: Image.asset(
                            "assets/icons/wte_icon.png",
                            fit: BoxFit.cover,
                          )),
                    ),
                    Text(
                      "WTE",
                      style: TextStyle(
                          fontFamily: "ARIAL",
                          color: Colors.white,
                          height: 0.4,
                          fontWeight: FontWeight.bold,
                          fontSize: 8.sp),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox(),
    );
  }

  Widget wteHomeScreen(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          widget.roles.contains("MSW-Sitehead")
              ? const SizedBox(
                  height: 10.0,
                )
              : const SizedBox(),
          widget.roles.contains("MSW-Sitehead")
              ? FutureBuilder(
                  future: getSiteID(),
                  builder: (context, snapshot) {
                    return Center(
                      child: Text(
                        "${snapshot.data}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontFamily: "ARIAL",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
            child: Row(
              children: [
                SizedBox(
                  width: 0.5.h,
                ),
                widget.roles.contains("MSW-Sbuhead") == false
                    ? Container(
                        alignment: Alignment.centerLeft,
                        height: 35,
                        width: 230,
                        child: TextField(
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 33,
                                fontFamily: "ARIAL",
                                color: Colors.black),
                            textAlign: TextAlign.left,
                            readOnly: true,
                            controller: dateInputController,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.only(top: 10, left: 10.0),
                              hintText: "Select Date",
                              hintStyle: const TextStyle(
                                fontSize: 13.0,
                                fontFamily: "ARIAL",
                                color: Colors.black,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    width: 1.1, color: inactiveColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    width: 1.1, color: inactiveColor),
                              ),
                              border: InputBorder.none,
                              suffixIcon: InkWell(
                                onTap: () async {
                                  isDateSelect == false
                                      ? pickDateRange()
                                      : setState(() {
                                          newDateRange = null;
                                          dateInputController.clear();
                                          isDateSelect = false;

                                          getConnectivity();
                                        });
                                },
                                child: Icon(
                                  isDateSelect
                                      ? Icons.cancel_outlined
                                      : Icons.calendar_month_outlined,
                                  color: inactiveColor,
                                ),
                              ),
                            ),
                            autofocus: false,
                            onTap: () async {
                              pickDateRange();
                            }))
                    : const SizedBox(),
                widget.roles.contains("MSW-Sbuhead")
                    ? Expanded(
                        flex: 3,
                        child: Container(
                            alignment: Alignment.centerLeft,
                            height: 35,
                            width: 230,
                            child: TextField(
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 33,
                                    fontFamily: "ARIAL",
                                    color: Colors.black),
                                textAlign: TextAlign.left,
                                readOnly: true,
                                controller: dateInputController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      top: 10, left: 10.0),
                                  hintText: "Select Date",
                                  hintStyle: const TextStyle(
                                    fontSize: 13.0,
                                    fontFamily: "ARIAL",
                                    color: Colors.black,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        width: 1.1, color: inactiveColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        width: 1.1, color: inactiveColor),
                                  ),
                                  border: InputBorder.none,
                                  suffixIcon: InkWell(
                                    onTap: () async {
                                      isDateSelect == false
                                          ? pickDateRange()
                                          : setState(() {
                                              newDateRange = null;
                                              dateInputController.clear();
                                              isDateSelect = false;

                                              getConnectivity();
                                            });
                                    },
                                    child: Icon(
                                      isDateSelect
                                          ? Icons.cancel_outlined
                                          : Icons.calendar_month_outlined,
                                      color: inactiveColor,
                                    ),
                                  ),
                                ),
                                autofocus: false,
                                onTap: () async {
                                  pickDateRange();
                                })),
                      )
                    : const SizedBox(),
                SizedBox(
                  width: 3.w,
                ),
                widget.roles.contains("MSW-Sbuhead")
                    ? Expanded(
                        flex: 2,
                        child: ValueListenableBuilder(
                          valueListenable: siteDataListValueNotifier,
                          builder: (BuildContext ctx,
                              List<SiteDataListResponseModel> dataList,
                              Widget? child) {
                            if (dataList.isNotEmpty) {
                              return DropdownButtonHideUnderline(
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color:
                                        kWhite, // Background color of the dropdown
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(
                                        color: inactiveColor), // Border color
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: DropdownButton<String>(
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors
                                            .grey, // Replace with your inactiveColor
                                      ),
                                      iconSize: 25.0,
                                      style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors
                                              .black), // Replace with kColorBlack
                                      value: _selectedSite == ""
                                          ? dataList[0].siteName
                                          : _selectedSite,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedSite = newValue!;
                                          _siteID = dataList
                                              .firstWhere((element) =>
                                                  element.siteName == newValue)
                                              .siteId!;
                                          getConnectivity();
                                        });
                                      },
                                      items: dataList.map<
                                              DropdownMenuItem<String>>(
                                          (SiteDataListResponseModel value) {
                                        return DropdownMenuItem<String>(
                                          value: value.siteName,
                                          child: Text(
                                            value.siteName!,
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.black),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                      )
                    : const SizedBox(),
                SizedBox(
                  width: 2.w,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          _tabSection(context),
        ],
      ),
    );
  }

  Widget _tabSection(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Padding(
        padding: const EdgeInsets.only(right: 0.0, left: 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                indicator: UnderlineTabIndicator(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                      width: 4.0,
                      color: kReSustainabilityRed,
                      style: BorderStyle.solid),
                ),
                indicatorColor: kReSustainabilityRed,
                controller: _homeTabController,
                tabs: const [
                  Tab(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text('RDF',
                            style: TextStyle(
                                fontSize: 13.0,
                                color: kColorBlack,
                                fontWeight: FontWeight.w500))),
                  ),
                  Tab(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text('Generation',
                            style: TextStyle(
                                fontSize: 13.0,
                                color: kColorBlack,
                                fontWeight: FontWeight.w500))),
                  ),
                  Tab(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text('Ash',
                            style: TextStyle(
                                fontSize: 13.0,
                                color: kColorBlack,
                                fontWeight: FontWeight.w500))),
                  ),
                ]),
            ListView(
              scrollDirection: Axis.vertical,
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: TabBarView(
                    controller: _homeTabController,
                    children: [rdfTab(), generationTab(), ashTab()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget rdfTab() {
    return ListView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ValueListenableBuilder(
            valueListenable: mswWteDataListValueNotifier,
            builder: (BuildContext ctx,
                List<MswWteDataListResponseModel> mswWteDataList,
                Widget? child) {
              if (mswWteDataList.isNotEmpty) {
                mswWteDataList
                    .sort((b, a) => a.mswWteDate.compareTo(b.mswWteDate));

                return Column(
                  children: [
                    widget.roles.contains("MSW-Sitehead") ||
                            widget.roles.contains("MSW-Sbuhead")
                        ? SizedBox(
                            height: 35.h,
                            child: RdfSummary(
                                receiptSum:
                                    mswWteDataList[0].rdfReceiptSum.toString(),
                                combustedSum: mswWteDataList[0]
                                    .rdfCombustedSum
                                    .toString(),
                                ashGenerated: mswWteDataList[0]
                                    .ashGeneratedSum
                                    .toString()))
                        : const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
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
                        child: CarouselSlider(
                          items: rdfDataList
                              .map(
                                (item) => rdfCarouselContent(
                                    item["data_type"], mswWteDataList),
                              )
                              .toList(),
                          carouselController: carouselController,
                          options: CarouselOptions(
                            height: MediaQuery.of(context).size.height * 0.4,
                            aspectRatio: 16 / 9,
                            scrollPhysics: const BouncingScrollPhysics(),
                            enableInfiniteScroll: true,
                            autoPlay: false,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) {
                              setState(() {
                                recycleIndex = index;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: rdfDataList.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () =>
                              carouselController.animateToPage(entry.key),
                          child: Container(
                            width: recycleIndex == entry.key ? 7 : 7,
                            height: 1.h,
                            margin: EdgeInsets.symmetric(
                              horizontal: 2.w,
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: recycleIndex == entry.key
                                    ? kReSustainabilityRed
                                    : kGreyTitleColor),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    widget.roles.contains("MSW-Sitehead") ||
                            widget.roles.contains("MSW-Sbuhead")
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox.fromSize(
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: kLightGrayColor,
                                    borderRadius: BorderRadius.circular(15.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: const Offset(
                                            0, 1), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(children: [
                                          Expanded(
                                              child: Text("Date",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: kGreyTitleColor))),
                                          Expanded(
                                              child: Text("RDF Receipt\n(MT)",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: kGreyTitleColor))),
                                          Expanded(
                                              child: Text("RDF Combusted\n(MT)",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: kGreyTitleColor))),
                                        ]),
                                      ),
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          itemCount:
                                              mswWteDataList.take(10).length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return rdfCard(
                                                mswWteDataList[index]);
                                          }),
                                    ],
                                  )),
                            ),
                          ),
                    SizedBox(
                      height: Platform.isIOS ? 40.h : 35.h,
                    ),
                  ],
                );
              } else {
                return Column(children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 9,
                  ),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/empty_data_img.png',
                          scale: 0.5.h,
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        const Text(
                            "Its look like you have no collection data to view",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14.0,
                                color: kGreyTitleColor,
                                fontWeight: FontWeight.w600)),
                        SizedBox(
                          height: 3.h,
                        ),
                        SizedBox(
                          width: 75.w,
                          child: const Text(
                              "Once the Collection data is added by the user, the data will reflect here",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: kGreyTitleColor,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ]);
              }
            },
          ),
        )
      ],
    );
  }

  Widget rdfCard(MswWteDataListResponseModel rdfDataListResponseModel) {
    return Container(
      width: double.infinity,
      color: kWhite,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  DateFormat('dd/MM/yyyy').format(
                      DateTime.parse(rdfDataListResponseModel.mswWteDate)),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: kColorBlack,
                      fontSize: 9.5.sp,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400),
                )),
                Container(
                  height: 40.0,
                  width: 0.3,
                  color: kGreyTitleColor,
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                     formatNumber(double.tryParse(rdfDataListResponseModel.rdfReceipt.toString())!),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: kColorBlack,
                          fontSize: 9.5.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                )),
                Container(
                  height: 40.0,
                  width: 0.3,
                  color: kGreyTitleColor,
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatNumber(double.tryParse(rdfDataListResponseModel.rdfCombusted.toString())!),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: kColorBlack,
                          fontSize: 9.5.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ))
              ],
            ),
          ),
          const Divider(
            color: kGreyTitleColor,
            height: 0.5,
            thickness: 0.3,
          )
        ],
      ),
    );
  }

  Widget generationTab() {
    return ListView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ValueListenableBuilder(
            valueListenable: mswWteDataListValueNotifier,
            builder: (BuildContext ctx,
                List<MswWteDataListResponseModel> mswWteDataList,
                Widget? child) {
              if (mswWteDataList.isNotEmpty) {
                mswWteDataList
                    .sort((b, a) => a.mswWteDate.compareTo(b.mswWteDate));
                mswWteDataList.take(10);
                return Column(
                  children: [
                    widget.roles.contains("MSW-Sitehead") ||
                            widget.roles.contains("MSW-Sbuhead")
                        ? SizedBox(
                            height: 300,
                            child: Generationsummary(
                              steamGen: mswWteDataList[0]
                                  .streamGenerationSum
                                  .toString(),
                              powerGen: mswWteDataList[0]
                                  .powerGenerationSum
                                  .toString(),
                              powerExport:
                                  mswWteDataList[0].powerExportSum.toString(),
                            ))
                        : const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
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
                        child: CarouselSlider(
                          items: generationDataList
                              .map(
                                (item) => generationCarouselContent(
                                    item["data_type"], mswWteDataList),
                              )
                              .toList(),
                          carouselController: carouselController,
                          options: CarouselOptions(
                            height: MediaQuery.of(context).size.height * 0.4,
                            aspectRatio: 16 / 9,
                            scrollPhysics: const BouncingScrollPhysics(),
                            enableInfiniteScroll: true,
                            autoPlay: false,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) {
                              setState(() {
                                recycleIndex = index;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: generationDataList.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () =>
                              carouselController.animateToPage(entry.key),
                          child: Container(
                            width: recycleIndex == entry.key ? 7 : 7,
                            height: 1.h,
                            margin: EdgeInsets.symmetric(
                              horizontal: 2.w,
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: recycleIndex == entry.key
                                    ? kReSustainabilityRed
                                    : kGreyTitleColor),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    widget.roles.contains("MSW-Sitehead") ||
                            widget.roles.contains("MSW-Sbuhead")
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              height: 37.0 +
                                  (mswWteDataList.length.clamp(0, 10) * 6.h),
                              decoration: BoxDecoration(
                                color: kLightGrayColor,
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: const Offset(
                                        0, 1), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  DataTable(
                                    border: const TableBorder(
                                        verticalInside: BorderSide(
                                            color: kGreyDivider, width: 1.0)),
                                    columnSpacing: 20.0.sp,
                                    columns: const [
                                      DataColumn(
                                          label: Text("Date",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: kGreyTitleColor))),
                                      DataColumn(
                                          label: Text(
                                              "Steam\n Generation\n(TPD)",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: kGreyTitleColor))),
                                      DataColumn(
                                          label: Text(
                                              "Power\n Generation\n(MW)",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: kGreyTitleColor))),
                                      DataColumn(
                                          label: Text("Power\n Export\n(MW)",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: kGreyTitleColor))),
                                      DataColumn(
                                          label: Text(
                                              "Auxiliary\n Consumption\n(MW)",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: kGreyTitleColor))),
                                      DataColumn(
                                          label: Text(
                                              "Power\n Generation Capacity\n(MW)",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: kGreyTitleColor))),
                                      DataColumn(
                                          label: Text(
                                              "Plant\n Load Factor\n(%)",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: kGreyTitleColor))),
                                    ],
                                    rows: mswWteDataList.take(10).map((item) {
                                      return DataRow(
                                        color: WidgetStateProperty.all(
                                            Colors.white),
                                        cells: [
                                          DataCell(Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                                DateFormat('dd/MM/yyyy').format(
                                                    DateTime.parse(
                                                        item.mswWteDate)),
                                                style: TextStyle(
                                                    color: kColorBlack,
                                                    fontSize: 9.0.sp,
                                                    fontFamily: 'Roboto',
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          )),
                                          DataCell(Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                formatNumber(double.tryParse(item.streamGeneration)!),
                                                style: TextStyle(
                                                    color: kColorBlack,
                                                    fontSize: 9.0.sp,
                                                    fontFamily: 'Roboto',
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          )),
                                          DataCell(Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                formatNumber(double.tryParse(
                                                        item.powerGeneration)!),
                                                style: TextStyle(
                                                    color: kColorBlack,
                                                    fontSize: 9.0.sp,
                                                    fontFamily: 'Roboto',
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          )),
                                          DataCell(Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                formatNumber(double.tryParse(item.powerExport)!),
                                                style: TextStyle(
                                                    color: kColorBlack,
                                                    fontSize: 9.0.sp,
                                                    fontFamily: 'Roboto',
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          )),
                                          DataCell(Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                formatNumber(double.tryParse(item
                                                        .auxillaryConsumption)!),
                                                style: TextStyle(
                                                    color: kColorBlack,
                                                    fontSize: 9.0.sp,
                                                    fontFamily: 'Roboto',
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          )),
                                          DataCell(Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                formatNumber(double.tryParse(item
                                                        .powerGenerationCapacity)!),
                                                style: TextStyle(
                                                    color: kColorBlack,
                                                    fontSize: 9.0.sp,
                                                    fontFamily: 'Roboto',
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          )),
                                          DataCell(Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                formatNumber(double.tryParse(
                                                        item.plantLoadFactor)!),
                                                style: TextStyle(
                                                    color: kColorBlack,
                                                    fontSize: 9.0.sp,
                                                    fontFamily: 'Roboto',
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          )),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    SizedBox(
                      height: Platform.isIOS ? 40.h : 35.h,
                    ),
                  ],
                );
              } else {
                return Column(children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 9,
                  ),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/empty_data_img.png',
                          scale: 0.5.h,
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        const Text(
                            "Its look like you have no collection data to view",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14.0,
                                color: kGreyTitleColor,
                                fontWeight: FontWeight.w600)),
                        SizedBox(
                          height: 3.h,
                        ),
                        SizedBox(
                          width: 75.w,
                          child: const Text(
                              "Once the Collection data is added by the user, the data will reflect here",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: kGreyTitleColor,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ]);
              }
            },
          ),
        )
      ],
    );
  }

  Widget generationCarouselContent(
      String dataType, List<MswWteDataListResponseModel> generationDataList) {
    if (dataType == "steamGen") {
      if (generationDataList.isNotEmpty) {
        steamGenerationList.clear();
        for (MswWteDataListResponseModel data in generationDataList) {
          if (steamGenerationList.length < 5) {
            steamGenerationList.add(OrdinalData(
                domain: data.mswWteDate.split("-")[2],
                measure: double.parse(data.streamGeneration),
                color: kReSustainabilityRed));
          }
        }
        return SizedBox(
          height: MediaQuery.of(context).size.height * 38,
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
                          const Text("Steam Generation Trend",
                              style: TextStyle(
                                  fontSize: 12.0, color: kColorBlack)),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: kReSustainabilityRed,
                                width: 1, // Adjust the border width as needed
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text("Weight in TPD",
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
                    padding: const EdgeInsets.only(left: 25.0, bottom: 5.0),
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
                          color: kGenStream,
                          data: steamGenerationList,
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
        return Column(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 3,
          ),
          const Center(
            child: Text("No Result Available",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.0,
                    color: kGreyTitleColor,
                    fontWeight: FontWeight.w600)),
          ),
        ]);
      }
    } else if (dataType == "powerGen") {
      if (generationDataList.isNotEmpty) {
        powerGenerationList.clear();
        for (MswWteDataListResponseModel data in generationDataList) {
          if (powerGenerationList.length < 5) {
            powerGenerationList.add(OrdinalData(
                domain: data.mswWteDate.split("-")[2],
                measure: double.parse(data.powerGeneration),
                color: kGenPowerGen));
          }
        }
        return Center(
            child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.38,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SizedBox(
                          height: 30.0,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Power Generation Trend",
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
                                    child: Text("Weight in MW",
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
                          padding: const EdgeInsets.only(left: 25.0, top: 5.0),
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
                                color: kGenPowerGen,
                                data: powerGenerationList,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      const Text("Date",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.0, color: kColorBlack))
                    ],
                  ),
                )));
      } else {
        return const Center(
          child: Text("No Record Available"),
        );
      }
    } else if (dataType == "powerExport") {
      if (generationDataList.isNotEmpty) {
        powerExportList.clear();
        for (MswWteDataListResponseModel data in generationDataList) {
          if (powerExportList.length < 5) {
            powerExportList.add(OrdinalData(
                domain: data.mswWteDate.split("-")[2],
                measure: double.parse(data.powerExport),
                color: kGenPowerExport));
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
                          const Text("Power Export Trend",
                              style: TextStyle(
                                  fontSize: 12.0, color: kColorBlack)),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: kReSustainabilityRed,
                                width: 1, // Adjust the border width as needed
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text("Weight in MW",
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
                    padding: const EdgeInsets.only(left: 25.0, bottom: 5.0),
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
                          color: kGenPowerExport,
                          data: powerExportList,
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
    } else if (dataType == "powerGenCap") {
      if (generationDataList.isNotEmpty) {
        powerGenerationCapacityList.clear();
        for (MswWteDataListResponseModel data in generationDataList) {
          if (powerGenerationCapacityList.length < 5) {
            powerGenerationCapacityList.add(OrdinalData(
                domain: data.mswWteDate.split("-")[2],
                measure: double.parse(data.powerGenerationCapacity),
                color: kGenPowerExport));
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
                          const Text("Power Generation capacity Trend",
                              style: TextStyle(
                                  fontSize: 12.0, color: kColorBlack)),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: kReSustainabilityRed,
                                width: 1, // Adjust the border width as needed
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text("Weight in MW",
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
                    padding: const EdgeInsets.only(left: 25.0, bottom: 5.0),
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
                          color: kGenPowerGenCap,
                          data: powerGenerationCapacityList,
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
    } else if (dataType == "auxConsumption") {
      if (generationDataList.isNotEmpty) {
        auxillaryConsumptionList.clear();
        for (MswWteDataListResponseModel data in generationDataList) {
          if (auxillaryConsumptionList.length < 5) {
            auxillaryConsumptionList.add(OrdinalData(
                domain: data.mswWteDate.split("-")[2],
                measure: double.parse(data.auxillaryConsumption),
                color: kGenPowerExport));
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
                          const Text("Auxiliary Consumption Trend",
                              style: TextStyle(
                                  fontSize: 12.0, color: kColorBlack)),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: kReSustainabilityRed,
                                width: 1, // Adjust the border width as needed
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text("Weight in MW",
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
                    padding: const EdgeInsets.only(left: 25.0, bottom: 5.0),
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
                          color: kGenAuxConsumption,
                          data: auxillaryConsumptionList,
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
    } else if (dataType == "plantLoadFactor") {
      if (generationDataList.isNotEmpty) {
        plantLoadFactorList.clear();
        for (MswWteDataListResponseModel data in generationDataList) {
          if (plantLoadFactorList.length < 5) {
            plantLoadFactorList.add(OrdinalData(
                domain: data.mswWteDate.split("-")[2],
                measure: double.parse(data.auxillaryConsumption),
                color: kGenPowerExport));
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
                          const Text("Plant Load Factor Trend",
                              style: TextStyle(
                                  fontSize: 12.0, color: kColorBlack)),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: kReSustainabilityRed,
                                width: 1, // Adjust the border width as needed
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text("Weight in %",
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
                    padding: const EdgeInsets.only(left: 25.0, bottom: 5.0),
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
                          color: kGenPlantLoadFactor,
                          data: plantLoadFactorList,
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
    } else {
      return const Center(
        child: Text("No Record Available"),
      );
    }
  }

  Widget rdfCarouselContent(
      String dataType, List<MswWteDataListResponseModel> mswWteDataList) {
    if (dataType == "rdfReceipt") {
      if (mswWteDataList.isNotEmpty) {
        rdfReceiptList.clear();
        for (MswWteDataListResponseModel data in mswWteDataList) {
          if (rdfReceiptList.length < 5) {
            rdfReceiptList.add(OrdinalData(
                domain: data.mswWteDate.split("-")[2],
                measure: double.parse(data.rdfReceipt),
                color: kReSustainabilityRed));
          }
        }
        return SizedBox(
          height: MediaQuery.of(context).size.height * 38,
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
                          const Text("RDF Trend",
                              style: TextStyle(
                                  fontSize: 12.0, color: kColorBlack)),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: kReSustainabilityRed,
                                width: 1, // Adjust the border width as needed
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
                          Row(
                            children: [
                              ClipOval(
                                  child: Container(
                                height: 15,
                                width: 15,
                                color: kChartBarColor,
                              )),
                              const SizedBox(width: 5.0),
                              const Text("Receipt",
                                  style: TextStyle(
                                      fontSize: 12.0, color: kColorBlack))
                            ],
                          )
                        ]),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25.0, bottom: 5.0),
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
                          data: rdfReceiptList,
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
        return Column(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 3,
          ),
          const Center(
            child: Text("No Result Available",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.0,
                    color: kGreyTitleColor,
                    fontWeight: FontWeight.w600)),
          ),
        ]);
      }
    } else if (dataType == "rdfCombusted") {
      if (mswWteDataList.isNotEmpty) {
        rdfCombustedList.clear();
        for (MswWteDataListResponseModel data in mswWteDataList) {
          if (rdfCombustedList.length < 5) {
            rdfCombustedList.add(OrdinalData(
                domain: data.mswWteDate.split("-")[2],
                measure: double.parse(data.rdfCombusted),
                color: kRdfCombust));
          }
        }
        return Center(
            child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.38,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SizedBox(
                          height: 30.0,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("RDF Combusted Trend",
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
                                Row(
                                  children: [
                                    ClipOval(
                                        child: Container(
                                      height: 15,
                                      width: 15,
                                      color: kRdfCombust,
                                    )),
                                    const SizedBox(width: 5.0),
                                    const Text("Combusted",
                                        style: TextStyle(
                                            fontSize: 12.0, color: kColorBlack))
                                  ],
                                )
                              ]),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25.0, top: 5.0),
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
                                color: kRdfCombust,
                                data: rdfCombustedList,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      const Text("Date",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.0, color: kColorBlack))
                    ],
                  ),
                )));
      } else {
        return const Center(
          child: Text("No Record Available"),
        );
      }
    } else {
      return const Center(
        child: Text("No Record Available"),
      );
    }
  }

  Widget ashTab() {
    return ListView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ValueListenableBuilder(
            valueListenable: mswWteDataListValueNotifier,
            builder: (BuildContext ctx,
                List<MswWteDataListResponseModel> mswWteDataList,
                Widget? child) {
              if (mswWteDataList.isNotEmpty) {
                mswWteDataList
                    .sort((b, a) => a.mswWteDate.compareTo(b.mswWteDate));

                return Column(
                  children: [
                    widget.roles.contains("MSW-Sitehead") ||
                            widget.roles.contains("MSW-Sbuhead")
                        ? SizedBox(
                            height: 300,
                            child: AshSummary(
                                bottomAsh:
                                    mswWteDataList[0].bottomAshSum.toString(),
                                flyAsh: mswWteDataList[0].flyAshSum.toString(),
                                totalAsh: (num.parse(mswWteDataList[0]
                                            .bottomAshSum
                                            .toString()) +
                                        num.parse(mswWteDataList[0]
                                            .flyAshSum
                                            .toString()))
                                    .toString()),
                          )
                        : const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
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
                        child: CarouselSlider(
                          items: ashDataList
                              .map(
                                (item) => ashCarouselContent(
                                    item["data_type"], mswWteDataList),
                              )
                              .toList(),
                          carouselController: carouselController,
                          options: CarouselOptions(
                            height: MediaQuery.of(context).size.height * 0.4,
                            aspectRatio: 16 / 9,
                            scrollPhysics: const BouncingScrollPhysics(),
                            enableInfiniteScroll: true,
                            autoPlay: false,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) {
                              setState(() {
                                recycleIndex = index;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ashDataList.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () =>
                              carouselController.animateToPage(entry.key),
                          child: Container(
                            width: recycleIndex == entry.key ? 7 : 7,
                            height: 1.h,
                            margin: EdgeInsets.symmetric(
                              horizontal: 2.w,
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: recycleIndex == entry.key
                                    ? kReSustainabilityRed
                                    : kGreyTitleColor),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    widget.roles.contains("MSW-Sitehead") ||
                            widget.roles.contains("MSW-Sbuhead")
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                  color: kLightGrayColor,
                                  borderRadius: BorderRadius.circular(15.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: const Offset(
                                          0, 1), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(children: [
                                        Expanded(
                                            flex: 3,
                                            child: Text("Date",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        Expanded(
                                            flex: 2,
                                            child: Text("Bottom Ash\n (MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        Expanded(
                                            flex: 2,
                                            child: Text("Fly Ash\n (MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        Expanded(
                                            flex: 2,
                                            child: Text("Total Ash\n (MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                      ]),
                                    ),
                                    ListView.builder(
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                        itemCount:
                                            mswWteDataList.take(10).length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return ashCard(mswWteDataList[index]);
                                        }),
                                  ],
                                )),
                          ),
                    SizedBox(
                      height: Platform.isIOS ? 40.h : 35.h,
                    ),
                  ],
                );
              } else {
                return Column(children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 9,
                  ),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/empty_data_img.png',
                          scale: 0.5.h,
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        const Text(
                            "Its look like you have no collection data to view",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14.0,
                                color: kGreyTitleColor,
                                fontWeight: FontWeight.w600)),
                        SizedBox(
                          height: 3.h,
                        ),
                        SizedBox(
                          width: 75.w,
                          child: const Text(
                              "Once the Collection data is added by the user, the data will reflect here",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: kGreyTitleColor,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ]);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget ashCard(MswWteDataListResponseModel mswWteDataListResponseModel) {
    return Container(
      color: kWhite,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(DateTime.parse(
                          mswWteDataListResponseModel.mswWteDate)),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kColorBlack,
                          fontSize: 9.5.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400),
                    )),
                Container(
                  height: 45.0,
                  width: 0.3,
                  color: kGreyTitleColor,
                ),
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 2.0),
                      child: Text(
                        formatNumber(double.tryParse(mswWteDataListResponseModel.bottomAsh)!),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: kColorBlack,
                            fontSize: 9.5.sp,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400),
                      ),
                    )),
                Container(
                  height: 45.0,
                  width: 0.2,
                  color: kGreyTitleColor,
                ),
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 2.0),
                      child: Text(
                        formatNumber(double.tryParse(mswWteDataListResponseModel.flyAsh)!),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: kColorBlack,
                            fontSize: 9.5.sp,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400),
                      ),
                    )),
                Container(
                  height: 45.0,
                  width: 0.2,
                  color: kGreyTitleColor,
                ),
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 2.0),
                      child: Text(
                        formatNumber(double.tryParse(mswWteDataListResponseModel.totalAsh)!),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: kColorBlack,
                            fontSize: 9.5.sp,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400),
                      ),
                    )),
              ],
            ),
          ),
          const Divider(
            color: kGreyTitleColor,
            height: 0.3,
            thickness: 0.5,
          )
        ],
      ),
    );
  }

  Widget ashCarouselContent(
      String dataType, List<MswWteDataListResponseModel> ashDataList) {
    if (dataType == "bottomAsh") {
      if (ashDataList.isNotEmpty) {
        bottomAshList.clear();
        for (MswWteDataListResponseModel data in ashDataList) {
          if (bottomAshList.length < 5) {
            bottomAshList.add(OrdinalData(
                domain: data.mswWteDate.split("-")[2],
                measure: double.parse(data.bottomAsh),
                color: kReSustainabilityRed));
          }
        }
        return SizedBox(
          height: MediaQuery.of(context).size.height * 38,
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
                          const Text("Ash Trend",
                              style: TextStyle(
                                  fontSize: 12.0, color: kColorBlack)),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: kReSustainabilityRed,
                                width: 1, // Adjust the border width as needed
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
                          Row(
                            children: [
                              ClipOval(
                                  child: Container(
                                height: 15,
                                width: 15,
                                color: kAshBottom,
                              )),
                              const SizedBox(width: 5.0),
                              const Text("Bottom Ash",
                                  style: TextStyle(
                                      fontSize: 12.0, color: kColorBlack))
                            ],
                          )
                        ]),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 26.0, bottom: 5.0),
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
                          color: kAshBottom,
                          data: bottomAshList,
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
        return Column(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 3,
          ),
          const Center(
            child: Text("No Result Available",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.0,
                    color: kGreyTitleColor,
                    fontWeight: FontWeight.w600)),
          ),
        ]);
      }
    } else if (dataType == "flyAsh") {
      if (ashDataList.isNotEmpty) {
        flyAshList.clear();
        for (MswWteDataListResponseModel data in ashDataList) {
          if (flyAshList.length < 5) {
            flyAshList.add(OrdinalData(
                domain: data.mswWteDate.split("-")[2],
                measure: double.parse(data.flyAsh),
                color: kReSustainabilityRed));
          }
        }
        return Center(
            child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.38,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SizedBox(
                          height: 30.0,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Ash Trend",
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
                                Row(
                                  children: [
                                    ClipOval(
                                        child: Container(
                                      height: 15,
                                      width: 15,
                                      color: kAshFly,
                                    )),
                                    const SizedBox(width: 5.0),
                                    const Text("Fly Ash",
                                        style: TextStyle(
                                            fontSize: 12.0, color: kColorBlack))
                                  ],
                                )
                              ]),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 26.0, top: 5.0),
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
                                color: kAshFly,
                                data: flyAshList,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      const Text("Date",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.0, color: kColorBlack))
                    ],
                  ),
                )));
      } else {
        return const Center(
          child: Text("No Record Available"),
        );
      }
    } else if (dataType == "totalAsh") {
      if (ashDataList.isNotEmpty) {
        totalAshList.clear();
        for (MswWteDataListResponseModel data in ashDataList) {
          if (totalAshList.length < 5) {
            totalAshList.add(OrdinalData(
                domain: data.mswWteDate.split("-")[2],
                measure: double.parse(data.totalAsh),
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
                          const Text("Ash Trend",
                              style: TextStyle(
                                  fontSize: 12.0, color: kColorBlack)),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: kReSustainabilityRed,
                                width: 1, // Adjust the border width as needed
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
                          Row(
                            children: [
                              ClipOval(
                                  child: Container(
                                height: 15,
                                width: 15,
                                color: kAshTotal,
                              )),
                              const SizedBox(width: 5.0),
                              const Text("Total Ash",
                                  style: TextStyle(
                                      fontSize: 12.0, color: kColorBlack))
                            ],
                          )
                        ]),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25.0, bottom: 5.0),
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
                          color: kAshTotal,
                          data: totalAshList,
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
    } else {
      return const Center(
        child: Text("No Record Available"),
      );
    }
  }

  Future pickDateRange() async {
    newDateRange = await showDateRangePicker(
      saveText: 'Search',
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
      useRootNavigator: false,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    setState(() {
      dateRange = newDateRange ?? dateRange;
      if (newDateRange == null) {
        if (dateRange.start ==
                DateTime.now().subtract(const Duration(days: 30)) &&
            dateRange.end == DateTime.now()) {
          dateInputController.text = "Select Date";
        }
      } else {
        dateInputController.text == "";
        isDateSelect = true;
        dateInputController.text =
            "${DateFormat('dd/MM/yyyy').format(dateRange.start)} to ${DateFormat('dd/MM/yyyy').format(dateRange.end)}";
        getConnectivity();
      }
    });
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

  getInit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _mswWteDataListRequestModel = MswWteDataListRequestModel();

    String siteID = prefs.getString("IRIS_SITE_ID").toString();
    String siteName = prefs.getString('IRIS_SITE_NAME').toString();

    if (_siteID == "") {
      for (int i = 0; i < siteDataListValueNotifier.value.length; i++) {
        if (siteID
            .contains(siteDataListValueNotifier.value[i].siteId.toString())) {
          _siteID = siteDataListValueNotifier.value[i].siteId.toString();
        }
        if (siteName
            .contains(siteDataListValueNotifier.value[i].siteName.toString())) {
          siteName = siteDataListValueNotifier.value[i].siteName.toString();
          prefs.setString('SITE_NAME', siteName);
          setState(() {
            _selectedSite =
                siteDataListValueNotifier.value[i].siteName.toString();
          });
        }
      }
    }

    GetMswWteDataListAPIService getMswCollectionDataListAPIService =
        GetMswWteDataListAPIService();
    getMswCollectionDataListAPIService.getMswWteDataListApiCall(
        _mswWteDataListRequestModel,
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.start),
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.end),
        _siteID);
    debugPrint("Site ID : $_siteID");
    prefs.setString("site", _siteID);
  }

  Future<String> getSiteID() {
    return MySharedPreferences.instance.getStringValue('IRIS_SITE_NAME');
  }
}
