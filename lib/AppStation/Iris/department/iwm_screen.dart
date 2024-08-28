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
import 'package:resus_test/AppStation/Iris/api/iwm/get_iwm_closestock_list_api.dart';
import 'package:resus_test/AppStation/Iris/api/iwm/get_iwm_disposal_list_api.dart';
import 'package:resus_test/AppStation/Iris/api/iwm/get_iwm_openstock_list_api.dart';
import 'package:resus_test/AppStation/Iris/api/iwm/get_iwm_receipt_list_api.dart';
import 'package:resus_test/AppStation/Iris/api/iwm/iwm_check_disposal_api.dart';
import 'package:resus_test/AppStation/Iris/api/iwm/iwm_check_openstock_api.dart';
import 'package:resus_test/AppStation/Iris/api/iwm/iwm_check_receipt_api.dart';
import 'package:resus_test/AppStation/Iris/model/iwm/iwm_closestock_data_model.dart';
import 'package:resus_test/AppStation/Iris/model/iwm/iwm_disposal_data_model.dart';
import 'package:resus_test/AppStation/Iris/model/iwm/iwm_openstock_data_model.dart';
import 'package:resus_test/AppStation/Iris/model/iwm/iwm_receipt_data_model.dart';
import 'package:resus_test/AppStation/Iris/summary/iwm_summary.dart';
import 'package:resus_test/Utility/utils/date_time_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../../Utility/MySharedPreferences.dart';
import '../../../Utility/internetCheck.dart';
import '../../../Utility/utils/constants.dart';
import '../form/iwm/iwm_form.dart';
import '../model/site_data_list_model.dart';

class IWMScreen extends StatefulWidget {
  final String selectSBU;
  final String roles;
  const IWMScreen({super.key, required this.selectSBU, required this.roles});

  @override
  State<IWMScreen> createState() => _IWMScreenState();
}

class _IWMScreenState extends State<IWMScreen>
    with SingleTickerProviderStateMixin {
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  late TextEditingController dateInputController = TextEditingController();
  late TabController tabController, _homeTabController;

  IwmOpenStockDataListRequestModel iwmOpenStockDataListRequestModel =
      IwmOpenStockDataListRequestModel();
  IwmReceiptDataListRequestModel iwmReceiptDataListRequestModel =
      IwmReceiptDataListRequestModel();
  IwmDisposalDataListRequestModel iwmDisposalDataListRequestModel =
      IwmDisposalDataListRequestModel();
  IwmCloseStockDataListRequestModel iwmCloseStockDataListRequestModel =
      IwmCloseStockDataListRequestModel();

  GetIwmOpenStockDataListAPIService getIwmOpenStockDataListAPIService =
      GetIwmOpenStockDataListAPIService();
  GetIwmReceiptDataListAPIService getIwmReceiptDataListAPIService =
      GetIwmReceiptDataListAPIService();
  GetIwmDisposalDataListAPIService getIwmDisposalDataListAPIService =
      GetIwmDisposalDataListAPIService();
  GetIwmCloseStockDataListAPIService getIwmCloseStockDataListAPIService =
      GetIwmCloseStockDataListAPIService();

  int scrollIndex = 0;
  bool isDateSelect = false;

  String selectedSBU = "";
  String _selectedSite = "";
  String _siteID = "";
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 100)),
    end: DateTime.now(),
  );

  late DateTimeRange? newDateRange;

  List<OrdinalData> openStockList = [];
  List<OrdinalData> receiptList = [];
  List<OrdinalData> disposalTotalWasteList = [];
  List<OrdinalData> disposalWasteList = [];
  List<OrdinalData> closingStockList = [];

  final List disposalChartList = [
    {"id": 1, "data_type": 'disposalTotalWaste'},
    {"id": 2, "data_type": 'disposalWaste'}
  ];

  String formatNumber(double number) {
    if (number == 0 || number < 1) {
      return number.toStringAsFixed(2);
    }
    final formatter = NumberFormat('#,###.00');
    String formattedNumber = formatter.format(number);
    return formattedNumber;
  }

  final CarouselController carouselController = CarouselController();

  @override
  void initState() {
    _homeTabController = TabController(vsync: this, length: 4);
    getConnectivity();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: iwmHomeScreen(context),
      bottomNavigationBar: widget.roles.contains("Ops Head")
          ? Container(
              height: Platform.isIOS ? 85 : 70,
              color: kReSustainabilityRed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          getReceiptForm();
                        },
                        child: SizedBox(
                            height: 60,
                            width: 60,
                            child: Image.asset(
                              "assets/icons/receipt.png",
                              fit: BoxFit.cover,
                            )),
                      ),
                      Text(
                        "Receipt",
                        style: TextStyle(
                            fontFamily: "ARIAL",
                            color: Colors.white,
                            height: 0.4,
                            fontWeight: FontWeight.bold,
                            fontSize: 8.sp),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          getDisposalForm();
                        },
                        child: SizedBox(
                            height: 60,
                            width: 60,
                            child: Image.asset(
                              "assets/icons/disposal.png",
                              fit: BoxFit.cover,
                            )),
                      ),
                      Text(
                        "Disposal",
                        style: TextStyle(
                            fontFamily: "ARIAL",
                            color: Colors.white,
                            height: 0.4,
                            fontWeight: FontWeight.bold,
                            fontSize: 8.sp),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const SizedBox(),
    );
  }

  Widget iwmHomeScreen(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          widget.roles.contains("Sitehead")
              ? const SizedBox(
                  height: 10.0,
                )
              : const SizedBox(),
          widget.roles.contains("Sitehead")
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
                widget.roles.contains("SBUHead") == false
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
                widget.roles.contains("SBUHead")
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
                widget.roles.contains("SBUHead")
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
      length: 4,
      child: Padding(
        padding: const EdgeInsets.only(right: 0.0, left: 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TabBar(
                physics: const AlwaysScrollableScrollPhysics(),
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.label,
                tabAlignment: TabAlignment.center,
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
                        child: Text('Opening Stock',
                            style: TextStyle(
                                fontSize: 13.0,
                                color: kColorBlack,
                                fontWeight: FontWeight.w500))),
                  ),
                  Tab(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text('Receipt',
                            style: TextStyle(
                                fontSize: 13.0,
                                color: kColorBlack,
                                fontWeight: FontWeight.w500))),
                  ),
                  Tab(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text('Disposal',
                            style: TextStyle(
                                fontSize: 13.0,
                                color: kColorBlack,
                                fontWeight: FontWeight.w500))),
                  ),
                  Tab(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text('Closing Stock',
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
                    children: [
                      InkWell(
                          onTap: () {
                            getIwmOpenStockDataListAPIService
                                .getIwmOpenStockDataListApiCall(
                                    iwmOpenStockDataListRequestModel,
                                    dateInputController.value.text == ""
                                        ? ""
                                        : DateFormat('yyyy-MM-dd')
                                            .format(dateRange.start),
                                    dateInputController.value.text == ""
                                        ? ""
                                        : DateFormat('yyyy-MM-dd')
                                            .format(dateRange.end),
                                    _siteID);
                          },
                          child: openStockTab()),
                      InkWell(
                          onTap: () {
                            getIwmReceiptDataListAPIService
                                .getIwmReceiptDataListApiCall(
                                    iwmReceiptDataListRequestModel,
                                    dateInputController.value.text == ""
                                        ? ""
                                        : DateFormat('yyyy-MM-dd')
                                            .format(dateRange.start),
                                    dateInputController.value.text == ""
                                        ? ""
                                        : DateFormat('yyyy-MM-dd')
                                            .format(dateRange.end),
                                    _siteID);
                          },
                          child: receiptTab()),
                      InkWell(
                          onTap: () {
                            getIwmDisposalDataListAPIService
                                .getIwmDisposalDataListApiCall(
                                    iwmDisposalDataListRequestModel,
                                    dateInputController.value.text == ""
                                        ? ""
                                        : DateFormat('yyyy-MM-dd')
                                            .format(dateRange.start),
                                    dateInputController.value.text == ""
                                        ? ""
                                        : DateFormat('yyyy-MM-dd')
                                            .format(dateRange.end),
                                    _siteID);
                          },
                          child: disposalTab()),
                      InkWell(
                          onTap: () {
                            getIwmCloseStockDataListAPIService
                                .getIwmCloseStockDataListApiCall(
                                    iwmCloseStockDataListRequestModel,
                                    dateInputController.value.text == ""
                                        ? ""
                                        : DateFormat('yyyy-MM-dd')
                                            .format(dateRange.start),
                                    dateInputController.value.text == ""
                                        ? ""
                                        : DateFormat('yyyy-MM-dd')
                                            .format(dateRange.end),
                                    _siteID);
                          },
                          child: closeStockTab())
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget openStockTab() {
    return ListView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ValueListenableBuilder(
            valueListenable: iwmOpenStockDataListValueNotifier,
            builder: (BuildContext ctx,
                List<IwmOpenStockDataListResponseModel> iwmOpenStockList,
                Widget? child) {
              if (iwmOpenStockList.isNotEmpty) {
                iwmOpenStockList.sort((b, a) => a.date.compareTo(b.date));
                openStockList.clear();
                for (IwmOpenStockDataListResponseModel data
                    in iwmOpenStockList) {
                  if (openStockList.length < 5) {
                    openStockList.add(OrdinalData(
                        domain: data.date.split("-")[2],
                        measure: num.parse(data.openStockTotalWaste),
                        color: kReSustainabilityRed));
                  }
                }

                return Column(
                  children: [
                    widget.roles.contains("SiteHead") ||
                            widget.roles.contains("SBUHead")
                        ? const IwmSummary()
                        : const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
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
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.36,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: SizedBox(
                                    height: 26.0,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Opening Stock Trend",
                                              style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: kColorBlack,
                                                  fontWeight: FontWeight.w500)),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: kReSustainabilityRed,
                                                width:
                                                    1, // Adjust the border width as needed
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                              ClipRect(
                                                  child: Container(
                                                height: 15,
                                                width: 15,
                                                color: kChartBarColor,
                                              )),
                                              const SizedBox(width: 5.0),
                                              const Text("Total Waste",
                                                  style: TextStyle(
                                                      fontSize: 11.0,
                                                      color: kColorBlack,
                                                      fontWeight:
                                                          FontWeight.w600))
                                            ],
                                          )
                                        ]),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.26,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25.0, top: 10.0, bottom: 10.0),
                                    child: DChartBarO(
                                      barLabelValue:
                                          (group, ordinalData, index) {
                                        return ordinalData.measure
                                            .round()
                                            .toString();
                                      },
                                      outsideBarLabelStyle:
                                          (group, ordinalData, index) {
                                        return const LabelStyle(
                                          fontSize: 8,
                                          color: kColorBlack,
                                        );
                                      },
                                      barLabelDecorator: BarLabelDecorator(
                                        barLabelPosition:
                                            BarLabelPosition.outside,
                                      ),
                                      configRenderBar: ConfigRenderBar(
                                        barGroupInnerPaddingPx: 2,
                                        barGroupingType:
                                            BarGroupingType.grouped,
                                        fillPattern: FillPattern.solid,
                                        maxBarWidthPx: 30,
                                        radius: 0,
                                        stackedBarPaddingPx: 1,
                                        strokeWidthPx: 0,
                                      ),
                                      groupList: [
                                        OrdinalGroup(
                                          id: '1',
                                          chartType: ChartType.bar,
                                          color: kChartBarColor,
                                          data: openStockList,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Text("Date",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12.0, color: kColorBlack)),
                                const SizedBox(
                                  height: 5.0,
                                ),
                              ],
                            ),
                          )),
                    ),
                    const SizedBox(height: 10.0),
                    widget.roles.contains("SiteHead") ||
                            widget.roles.contains("SBUHead")
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 5.0, bottom: 5.0),
                            child: SizedBox.fromSize(
                              child: Container(
                                height: 37.0 +
                                    (iwmOpenStockList.length.clamp(0, 10) *
                                        6.h),
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
                                      columnSpacing: 15.0.sp,
                                      columns: const [
                                        DataColumn(
                                            label: Text("Date",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("Total\nWaste \n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("DLF\n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("LAT \n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("Incineration\n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("AFRF\n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                      ],
                                      rows:
                                          iwmOpenStockList.take(10).map((item) {
                                        return DataRow(
                                          color: WidgetStateProperty.all(
                                              Colors.white),
                                          cells: [
                                            DataCell(Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                  DateFormat('dd/MM/yyyy')
                                                      .format(DateTime.parse(
                                                          item.date)),
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
                                                  formatNumber(double.tryParse(item.openStockTotalWaste)!),
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
                                                          item.openStockDlf)!),
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
                                                          item.openStockLat)!),
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
                                                          .openStockIncineration)!),
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
                                                          item.openStockAfrf)!),
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
                          ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    openStockSummaryCard(iwmOpenStockList[0]),
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

  Widget openStockSummaryCard(
      IwmOpenStockDataListResponseModel iwmOpenStockDataListResponseModel) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, right: 20.0, bottom: 10.0, top: 10.0),
      child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
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
                "Opening Stock Summary",
                style: TextStyle(fontWeight: FontWeight.w500),
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
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kSummaryBorderColor1,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Total Waste",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kBlueTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmOpenStockDataListResponseModel.openStockTotalWasteSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kBlueTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
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
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kSummaryBorderColor1,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("DLF",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kBlueTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmOpenStockDataListResponseModel.openStockDlfSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kBlueTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
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
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kSummaryBorderColor1,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("LAT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kBlueTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmOpenStockDataListResponseModel.openStockLatSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kBlueTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: 117.0,
                      height: 66.0,
                      decoration: BoxDecoration(
                          color: kSummaryBorderColor1,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.6),
                              spreadRadius: 0.5,
                              blurRadius: 2,
                              offset: const Offset(
                                  0, 4), // changes position of shadow
                            ),
                          ],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Incineration",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: kBlueTitleColor,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400)),
                          const SizedBox(height: 10.0),
                          Text(
                              "${formatNumber(iwmOpenStockDataListResponseModel.openStockIncinerationSum)} MT",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: kBlueTitleColor,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: 117.0,
                      height: 66.0,
                      decoration: BoxDecoration(
                          color: kSummaryBorderColor1,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.6),
                              spreadRadius: 0.5,
                              blurRadius: 2,
                              offset: const Offset(
                                  0, 4), // changes position of shadow
                            ),
                          ],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("AFRF",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: kBlueTitleColor,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400)),
                          const SizedBox(height: 10.0),
                          Text(
                              "${formatNumber(iwmOpenStockDataListResponseModel.openStockAfrfSum)} MT",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: kBlueTitleColor,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
            ],
          )),
    );
  }

  Widget receiptTab() {
    return ListView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ValueListenableBuilder(
            valueListenable: iwmReceiptDataListNotifier,
            builder: (BuildContext ctx,
                List<IwmReceiptDataListResponseModel> iwmReceiptList,
                Widget? child) {
              if (iwmReceiptList.isNotEmpty) {
                iwmReceiptList.sort((b, a) => a.date.compareTo(b.date));
                receiptList.clear();
                for (IwmReceiptDataListResponseModel data in iwmReceiptList) {
                  if (receiptList.length < 5) {
                    receiptList.add(OrdinalData(
                        domain: data.date.split("-")[2],
                        measure: num.parse(data.receiptTotalWaste),
                        color: kReSustainabilityRed));
                  }
                }

                return Column(
                  children: [
                    widget.roles.contains("SiteHead") ||
                            widget.roles.contains("SBUHead")
                        ? const IwmSummary()
                        : const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
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
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.36,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: SizedBox(
                                    height: 26.0,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Receipt Trend",
                                              style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: kColorBlack,
                                                  fontWeight: FontWeight.w500)),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: kReSustainabilityRed,
                                                width:
                                                    1, // Adjust the border width as needed
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                              ClipRect(
                                                  child: Container(
                                                height: 15,
                                                width: 15,
                                                color: kChartBarColor,
                                              )),
                                              const SizedBox(width: 5.0),
                                              const Text("Total Waste",
                                                  style: TextStyle(
                                                      fontSize: 11.0,
                                                      color: kColorBlack,
                                                      fontWeight:
                                                          FontWeight.w600))
                                            ],
                                          )
                                        ]),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.26,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25.0, top: 10.0, bottom: 10.0),
                                    child: DChartBarO(
                                      barLabelValue:
                                          (group, ordinalData, index) {
                                        return ordinalData.measure
                                            .round()
                                            .toString();
                                      },
                                      outsideBarLabelStyle:
                                          (group, ordinalData, index) {
                                        return const LabelStyle(
                                          fontSize: 8,
                                          color: kColorBlack,
                                        );
                                      },
                                      barLabelDecorator: BarLabelDecorator(
                                        barLabelPosition:
                                            BarLabelPosition.outside,
                                      ),
                                      configRenderBar: ConfigRenderBar(
                                        barGroupInnerPaddingPx: 2,
                                        barGroupingType:
                                            BarGroupingType.grouped,
                                        fillPattern: FillPattern.solid,
                                        maxBarWidthPx: 30,
                                        radius: 0,
                                        stackedBarPaddingPx: 1,
                                        strokeWidthPx: 0,
                                      ),
                                      groupList: [
                                        OrdinalGroup(
                                          id: '1',
                                          chartType: ChartType.bar,
                                          color: kChartBarColor,
                                          data: receiptList,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Text("Date",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12.0, color: kColorBlack)),
                                const SizedBox(
                                  height: 5.0,
                                ),
                              ],
                            ),
                          )),
                    ),
                    const SizedBox(height: 10.0),
                    widget.roles.contains("SiteHead") ||
                            widget.roles.contains("SBUHead")
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 5.0, bottom: 5.0),
                            child: SizedBox.fromSize(
                              child: Container(
                                height: 37.0 +
                                    (iwmReceiptList.length.clamp(0, 10) * 6.h),
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
                                      columnSpacing: 15.0.sp,
                                      columns: const [
                                        DataColumn(
                                            label: Text("Date",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("Total \nWaste \n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("DLF\n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("LAT \n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("Incineration\n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("AFRF\n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("Inci to AFRF\n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                      ],
                                      rows: iwmReceiptList.take(10).map((item) {
                                        return DataRow(
                                          color: WidgetStateProperty.all(
                                              Colors.white),
                                          cells: [
                                            DataCell(Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                  DateFormat('dd/MM/yyyy')
                                                      .format(DateTime.parse(
                                                          item.date)),
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
                                                  "${formatNumber(double.tryParse(item.receiptTotalWaste)!)}",
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
                                                  formatNumber(double.tryParse(item.receiptDlf)!),
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
                                                  formatNumber(double.tryParse(item.receiptLat)!),
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
                                                          .receiptIncineration)!),
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
                                                  formatNumber(double.tryParse(item.receiptAfrf)!),
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
                                                          .receiptIncinerationToAfrf)!),
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
                          ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    receiptSummaryCard(iwmReceiptList[0]),
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

  Widget receiptSummaryCard(
      IwmReceiptDataListResponseModel iwmReceiptDataListResponseModel) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, right: 20.0, bottom: 10.0, top: 10.0),
      child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
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
                "Receipt Summary",
                style: TextStyle(fontWeight: FontWeight.w500),
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
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kSummaryColor2,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Total Waste",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kGreenTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmReceiptDataListResponseModel.receiptTotalWasteSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kGreenTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
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
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kSummaryColor2,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("DLF",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kGreenTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmReceiptDataListResponseModel.receiptDlfSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kGreenTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
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
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kSummaryColor2,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("LAT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kGreenTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmReceiptDataListResponseModel.receiptLatSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kGreenTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: 117.0,
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kSummaryColor2,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Incineration",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kGreenTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmReceiptDataListResponseModel.receiptIncinerationSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kGreenTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: 117.0,
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kSummaryColor2,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("AFRF",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kGreenTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmReceiptDataListResponseModel.receiptAfrfSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kGreenTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: 117.0,
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kSummaryColor2,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Inci to AFRF",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kGreenTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmReceiptDataListResponseModel.receiptIncinerationToAfrfSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kGreenTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
            ],
          )),
    );
  }

  Widget disposalTab() {
    return ListView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ValueListenableBuilder(
            valueListenable: iwmDisposalDataListNotifier,
            builder: (BuildContext ctx,
                List<IwmDisposalDataListResponseModel> iwmDisposalList,
                Widget? child) {
              if (iwmDisposalList.isNotEmpty) {
                iwmDisposalList.sort((b, a) => a.date.compareTo(b.date));
                return Column(
                  children: [
                    widget.roles.contains("SiteHead") ||
                            widget.roles.contains("SBUHead")
                        ? const IwmSummary()
                        : const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.36,
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
                          items: disposalChartList
                              .map(
                                (item) => disposalCarouselContent(
                                    item["data_type"], iwmDisposalList),
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
                                scrollIndex = index;
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
                      children: disposalChartList.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () =>
                              carouselController.animateToPage(entry.key),
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
                    const SizedBox(height: 10.0),
                    widget.roles.contains("SiteHead") ||
                            widget.roles.contains("SBUHead")
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 5.0, bottom: 5.0),
                            child: SizedBox.fromSize(
                              child: Container(
                                height: 37.0 +
                                    (iwmDisposalList.length.clamp(0, 10) * 6.h),
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
                                      columnSpacing: 15.0.sp,
                                      columns: const [
                                        DataColumn(
                                            label: Text("Date",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("Total \nWaste \n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("DLF\n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("LAT \n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("Incineration\n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("AFRF\n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text("Inci to AFRF\n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text(
                                                "Recy Qty to \nIncineration\n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text(
                                                "Recy Qty to \nAFRF\n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        DataColumn(
                                            label: Text(
                                                "Recycling Total \nQty\n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                      ],
                                      rows:
                                          iwmDisposalList.take(10).map((item) {
                                        return DataRow(
                                          color: WidgetStateProperty.all(
                                              Colors.white),
                                          cells: [
                                            DataCell(Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                  DateFormat('dd/MM/yyyy')
                                                      .format(DateTime.parse(
                                                          item.date)),
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
                                                  formatNumber(double.tryParse(item.disposalTotalWaste)!),
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
                                                  formatNumber(double.tryParse(item.disposalDlf)!),
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
                                                  formatNumber(double.tryParse(item.disposalLat)!),
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
                                                          .disposalIncineration)!),
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
                                                          item.disposalAfrf)!),
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
                                                          .disposalIncinerationToAfrf)!),
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
                                                          .disposalRecycQtyInc)!),
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
                                                          .disposalRecycQtyAfrf)!),
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
                                                          .disposalRecycQtyTotal)!),
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
                          ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    disposalSummaryCard(iwmDisposalList[0]),
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

  Widget disposalSummaryCard(
      IwmDisposalDataListResponseModel iwmDisposalDataListResponseModel) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, right: 20.0, bottom: 10.0, top: 10.0),
      child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
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
                "Disposal Summary",
                style: TextStyle(fontWeight: FontWeight.w500),
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
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kRecyclableSummaryColor1,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Total Waste",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmDisposalDataListResponseModel.disposalTotalWasteSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
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
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kRecyclableSummaryColor1,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("DLF",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmDisposalDataListResponseModel.disposalDlfSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
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
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kRecyclableSummaryColor1,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("LAT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmDisposalDataListResponseModel.disposalLatSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: 117.0,
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kRecyclableSummaryColor1,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Incineration",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmDisposalDataListResponseModel.disposalIncinerationSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: 117.0,
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kRecyclableSummaryColor1,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("AFRF",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmDisposalDataListResponseModel.disposalAfrfSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: 117.0,
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kRecyclableSummaryColor1,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Inci to AFRF",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmDisposalDataListResponseModel.disposalIncinerationToAfrfSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: 117.0,
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kRecyclableSummaryColor1,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Recy Qty to Incineration",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmDisposalDataListResponseModel.disposalRecycQtyIncSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: 117.0,
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kRecyclableSummaryColor1,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Recy Qty to \nAFRF",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmDisposalDataListResponseModel.disposalRecycQtyAfrfSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: 117.0,
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kRecyclableSummaryColor1,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Recycling Total Qty",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmDisposalDataListResponseModel.disposalRecycQtyTotalSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kRecyclableTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
            ],
          )),
    );
  }

  Widget disposalCarouselContent(
      String dataType, List<IwmDisposalDataListResponseModel> iwmDisposalList) {
    if (dataType == "disposalTotalWaste") {
      if (iwmDisposalList.isNotEmpty) {
        disposalTotalWasteList.clear();
        for (IwmDisposalDataListResponseModel data in iwmDisposalList) {
          if (disposalTotalWasteList.length < 5) {
            disposalTotalWasteList.add(OrdinalData(
                domain: data.date.split("-")[2],
                measure: double.parse(data.disposalTotalWaste),
                color: kReSustainabilityRed));
          }
        }
        return SizedBox(
          height: MediaQuery.of(context).size.height * 37,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 30.0,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Disposal Trend",
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
                              ClipRect(
                                  child: Container(
                                height: 15,
                                width: 15,
                                color: kChartBarColor,
                              )),
                              const SizedBox(width: 5.0),
                              const Text("Total Waste",
                                  style: TextStyle(
                                      fontSize: 12.0, color: kColorBlack))
                            ],
                          )
                        ]),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.26,
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
                          data: disposalTotalWasteList,
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
    } else if (dataType == "disposalWaste") {
      if (iwmDisposalList.isNotEmpty) {
        disposalWasteList.clear();
        for (IwmDisposalDataListResponseModel data in iwmDisposalList) {
          if (disposalWasteList.length < 5) {
            disposalWasteList.add(OrdinalData(
                domain: data.date.split("-")[2],
                measure: double.parse(data.disposalRecycQtyTotal),
                color: kRdfCombust));
          }
        }
        return Center(
            child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.37,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 30.0,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Disposal Trend",
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
                                    ClipRect(
                                        child: Container(
                                      height: 15,
                                      width: 15,
                                      color: kRdfCombust,
                                    )),
                                    const SizedBox(width: 5.0),
                                    const Text("Total Disposal",
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
                                data: disposalWasteList,
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

  Widget closeStockTab() {
    return ListView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ValueListenableBuilder(
            valueListenable: iwmCloseStockDataListValueNotifier,
            builder: (BuildContext ctx,
                List<IwmCloseStockDataListResponseModel> iwmCloseStockList,
                Widget? child) {
              if (iwmCloseStockList.isNotEmpty) {
                iwmCloseStockList.sort((b, a) => a.date.compareTo(b.date));
                closingStockList.clear();
                for (IwmCloseStockDataListResponseModel data
                    in iwmCloseStockList) {
                  if (closingStockList.length < 5) {
                    closingStockList.add(OrdinalData(
                        domain: data.date.split("-")[2],
                        measure: num.parse(data.closeStockTotalWaste),
                        color: kReSustainabilityRed));
                  }
                }

                return Column(
                  children: [
                    widget.roles.contains("SiteHead") ||
                            widget.roles.contains("SBUHead")
                        ? const IwmSummary()
                        : const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
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
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.36,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: SizedBox(
                                    height: 26.0,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Closing Stock Trend",
                                              style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: kColorBlack,
                                                  fontWeight: FontWeight.w500)),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: kReSustainabilityRed,
                                                width:
                                                    1, // Adjust the border width as needed
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                              ClipRect(
                                                  child: Container(
                                                height: 15,
                                                width: 15,
                                                color: kChartBarColor,
                                              )),
                                              const SizedBox(width: 5.0),
                                              const Text("Total Waste",
                                                  style: TextStyle(
                                                      fontSize: 11.0,
                                                      color: kColorBlack,
                                                      fontWeight:
                                                          FontWeight.w600))
                                            ],
                                          )
                                        ]),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.26,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25.0, top: 10.0, bottom: 10.0),
                                    child: DChartBarO(
                                      barLabelValue:
                                          (group, ordinalData, index) {
                                        return ordinalData.measure
                                            .round()
                                            .toString();
                                      },
                                      outsideBarLabelStyle:
                                          (group, ordinalData, index) {
                                        return const LabelStyle(
                                          fontSize: 8,
                                          color: kColorBlack,
                                        );
                                      },
                                      barLabelDecorator: BarLabelDecorator(
                                        barLabelPosition:
                                            BarLabelPosition.outside,
                                      ),
                                      configRenderBar: ConfigRenderBar(
                                        barGroupInnerPaddingPx: 2,
                                        barGroupingType:
                                            BarGroupingType.grouped,
                                        fillPattern: FillPattern.solid,
                                        maxBarWidthPx: 30,
                                        radius: 0,
                                        stackedBarPaddingPx: 1,
                                        strokeWidthPx: 0,
                                      ),
                                      groupList: [
                                        OrdinalGroup(
                                          id: '1',
                                          chartType: ChartType.bar,
                                          color: kChartBarColor,
                                          data: closingStockList,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Text("Date",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12.0, color: kColorBlack)),
                                const SizedBox(
                                  height: 5.0,
                                ),
                              ],
                            ),
                          )),
                    ),
                    const SizedBox(height: 10.0),
                    if (widget.roles.contains("SiteHead") ||
                        widget.roles.contains("SBUHead"))
                      const SizedBox()
                    else
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 5.0, bottom: 5.0),
                        child: SizedBox.fromSize(
                          child: Container(
                            height: 37.0 +
                                (iwmCloseStockList.length.clamp(0, 10) * 6.h),
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
                                  columnSpacing: 15.0.sp,
                                  columns: const [
                                    DataColumn(
                                        label: Text("Date",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: kGreyTitleColor))),
                                    DataColumn(
                                        label: Text("Total \nWaste \n(MT)",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: kGreyTitleColor))),
                                    DataColumn(
                                        label: Text("DLF\n(MT)",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: kGreyTitleColor))),
                                    DataColumn(
                                        label: Text("LAT \n(MT)",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: kGreyTitleColor))),
                                    DataColumn(
                                        label: Text("Incineration\n(MT)",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: kGreyTitleColor))),
                                    DataColumn(
                                        label: Text("AFRF\n(MT)",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: kGreyTitleColor))),
                                  ],
                                  rows: iwmCloseStockList.take(10).map((item) {
                                    return DataRow(
                                      color:
                                          WidgetStateProperty.all(Colors.white),
                                      cells: [
                                        DataCell(Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                              DateFormat('dd/MM/yyyy').format(
                                                  DateTime.parse(item.date)),
                                              style: TextStyle(
                                                  color: kColorBlack,
                                                  fontSize: 9.0.sp,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w400)),
                                        )),
                                        DataCell(Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                              formatNumber(double.tryParse(item.closeStockTotalWaste)!),
                                              style: TextStyle(
                                                  color: kColorBlack,
                                                  fontSize: 9.0.sp,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w400)),
                                        )),
                                        DataCell(Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                              formatNumber(double.tryParse(item.closeStockDlf)!),
                                              style: TextStyle(
                                                  color: kColorBlack,
                                                  fontSize: 9.0.sp,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w400)),
                                        )),
                                        DataCell(Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                              formatNumber(double.tryParse(item.closeStockLat)!),
                                              style: TextStyle(
                                                  color: kColorBlack,
                                                  fontSize: 9.0.sp,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w400)),
                                        )),
                                        DataCell(Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                              formatNumber(double.tryParse(item
                                                      .closeStockIncineration)!),
                                              style: TextStyle(
                                                  color: kColorBlack,
                                                  fontSize: 9.0.sp,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w400)),
                                        )),
                                        DataCell(Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                              formatNumber(double.tryParse(item.closeStockAfrf)!),
                                              style: TextStyle(
                                                  color: kColorBlack,
                                                  fontSize: 9.0.sp,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w400)),
                                        )),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    closeStockSummaryCard(iwmCloseStockList[0]),
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

  Widget closeStockSummaryCard(
      IwmCloseStockDataListResponseModel iwmCloseStockDataListResponseModel) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, right: 20.0, bottom: 10.0, top: 10.0),
      child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
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
                "Closing Stock Summary",
                style: TextStyle(fontWeight: FontWeight.w500),
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
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kClosingStockSummary,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Total Waste",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kClosingStockTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmCloseStockDataListResponseModel.closeStockTotalWasteSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kClosingStockTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
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
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kClosingStockSummary,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("DLF",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kClosingStockTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmCloseStockDataListResponseModel.closeStockDlfSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kClosingStockTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
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
                        height: 66.0,
                        decoration: BoxDecoration(
                            color: kClosingStockSummary,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 4), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("LAT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kClosingStockTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(iwmCloseStockDataListResponseModel.closeStockLatSum)} MT",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: kClosingStockTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: 117.0,
                      height: 66.0,
                      decoration: BoxDecoration(
                          color: kClosingStockSummary,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.6),
                              spreadRadius: 0.5,
                              blurRadius: 2,
                              offset: const Offset(
                                  0, 4), // changes position of shadow
                            ),
                          ],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Incineration",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: kClosingStockTitleColor,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400)),
                          const SizedBox(height: 10.0),
                          Text(
                              "${formatNumber(iwmCloseStockDataListResponseModel.closeStockIncinerationSum)} MT",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: kClosingStockTitleColor,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: 117.0,
                      height: 66.0,
                      decoration: BoxDecoration(
                          color: kClosingStockSummary,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.6),
                              spreadRadius: 0.5,
                              blurRadius: 2,
                              offset: const Offset(
                                  0, 4), // changes position of shadow
                            ),
                          ],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("AFRF",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: kClosingStockTitleColor,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400)),
                          const SizedBox(height: 10.0),
                          Text(
                              "${formatNumber(iwmCloseStockDataListResponseModel.closeStockAfrfSum)} MT",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: kClosingStockTitleColor,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
            ],
          )),
    );
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

    getIwmOpenStockDataListAPIService.getIwmOpenStockDataListApiCall(
        iwmOpenStockDataListRequestModel,
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.start),
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.end),
        _siteID);

    getIwmReceiptDataListAPIService.getIwmReceiptDataListApiCall(
        iwmReceiptDataListRequestModel,
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.start),
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.end),
        _siteID);

    getIwmDisposalDataListAPIService.getIwmDisposalDataListApiCall(
        iwmDisposalDataListRequestModel,
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.start),
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.end),
        _siteID);

    getIwmCloseStockDataListAPIService.getIwmCloseStockDataListApiCall(
        iwmCloseStockDataListRequestModel,
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

  void showCustomAlertDialog(
      BuildContext context, String form, String receiptDate) {
    String formName = form;
    String title = formName == "Receipt"
        ? 'Submit Disposal Form for ${DateFormat('dd/MM/yyyy').format(DateTime.parse(receiptDate))}'
        : 'Submit Receipt Form first';
    String subTitle = formName == "Receipt"
        ? "Please Submit the Disposal form to process the Receipt further"
        : "Please Submit the Receipt form to process the Disposal further";
    showDialog(
      barrierDismissible: false,
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: "ARIAL",
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 2.h,
                ),
                Text(subTitle,
                    style: const TextStyle(
                      fontFamily: "ARIAL",
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center),
              ],
            ),
            actions: <Widget>[
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      backgroundColor: kReSustainabilityRed,
                      elevation: 3.0,
                      padding: const EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 40.0, right: 40.0)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: kWhite, fontSize: 14.0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void getDisposalForm() async {
    await GetIwmCheckReceiptDataListAPIService()
        .getIwmCheckReceiptDataListApiCall(
            iwmReceiptDataListRequestModel, _siteID);
    await GetIwmCheckOpenStockDataListAPIService()
        .getIwmCheckOpenStockDataListApiCall(
            iwmOpenStockDataListRequestModel, _siteID);
    await GetIwmCheckDisposalDataListAPIService()
        .getIwmCheckDisposalDataListApiCall(
            iwmDisposalDataListRequestModel, _siteID);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String receiptDate = prefs.getString("receiptLastDate").toString();
    String osDate = prefs.getString("osLastDate").toString();
    String disposalDate = prefs.getString("disposalLastDate").toString();
    print(osDate.contains(receiptDate) && receiptDate != disposalDate);
    print(receiptDate == disposalDate);

    if (osDate.contains(receiptDate) && receiptDate != disposalDate) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const IwmForm(
          formName: "Disposal",
        ),
      ));
    } else {
      showCustomAlertDialog(context, "Disposal", receiptDate);
    }
  }

  void getReceiptForm() async {
    await GetIwmCheckReceiptDataListAPIService()
        .getIwmCheckReceiptDataListApiCall(
            iwmReceiptDataListRequestModel, _siteID);
    await GetIwmCheckOpenStockDataListAPIService()
        .getIwmCheckOpenStockDataListApiCall(
            iwmOpenStockDataListRequestModel, _siteID);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String receiptDate = prefs.getString("receiptLastDate").toString();
    String osDate = prefs.getString("osLastDate").toString();

    if (osDate.contains(receiptDate)) {
      showCustomAlertDialog(context, "Receipt", receiptDate);
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const IwmForm(
          formName: "Receipt",
        ),
      ));
    }
  }
}
