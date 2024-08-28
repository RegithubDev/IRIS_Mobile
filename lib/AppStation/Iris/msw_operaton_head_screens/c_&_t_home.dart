import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:d_chart/d_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:resus_test/AppStation/Iris/api/get_msw_collection_api_list.dart';
import 'package:resus_test/AppStation/Iris/msw_operaton_head_screens/data_models/msw_distribute_data_list_model.dart';
import 'package:resus_test/AppStation/Iris/msw_operaton_head_screens/data_models/msw_process_data_list_model.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../../Utility/MySharedPreferences.dart';
import '../../../Utility/utils/constants.dart';
import '../api/get_iris_home_api_service.dart';
import '../model/collection_data_list_model.dart';
import '../model/iris_home_model.dart';
import '../model/site_data_list_model.dart';
import '../summary/collect_summary.dart';
import '../summary/processing_summary.dart';
import 'apis/get_msw_distribute_data_list_api.dart';
import 'apis/get_msw_pnd_data_list_api.dart';

class CAndTHomeScreen extends StatefulWidget {
  final String sbuCode;
  final String userRole;
  CAndTHomeScreen({super.key, required this.sbuCode, required this.userRole});

  @override
  State<CAndTHomeScreen> createState() => _CAndTHomeScreenState();
}

class _CAndTHomeScreenState extends State<CAndTHomeScreen>
    with SingleTickerProviderStateMixin {
  late IRISHomeRequestModel irisHomeRequestModel;
  DateRange? selectedDateRange;

  GoogleSignInAccount? m_googleSignInAccount;
  String m_user_id = "";
  String m_emailId = "";

  // late StreamSubscription subscriptionIrisHome;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  late TextEditingController dateInputController = TextEditingController();
  late TextEditingController sbuController = TextEditingController();
  late TabController tabController, _homeTabController;

  int currentIndex = 0;
  int scrollIndex = 0;
  int recycleIndex = 0;
  double collectWasteSum = 0.0;
  String _siteID = "";
  bool isDateSelect = false;

  late CollectionDataListRequestModel _irisHomeScreenDataListRequestModel;
  late MswProcessingDataListRequestModel _mswProcessingDataListRequestModel;
  late MswDistributeDataListRequestModel _mswDistributeDataListRequestModel;

  List<OrdinalData> ordinalDataList = [];

  Future<String> getSBUCode() {
    return MySharedPreferences.instance.getStringValue('IRIS_SBU_CODE');
  }

  List<OrdinalData> collectionList = [];

  String selectedSBU = "";
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 100)),
    end: DateTime.now(),
  );

  late DateTimeRange? newDateRange;

  String _selectedSite = "";

  List<OrdinalData> compostList = [];
  List<OrdinalData> rdfList = [];
  List<OrdinalData> recyclablesList = [];
  List<OrdinalData> inertsList = [];

  List<OrdinalData> compostOutflowList = [];
  List<OrdinalData> rdfOutflowList = [];
  List<OrdinalData> recyclablesOutflowList = [];
  List<OrdinalData> inertsOutflowList = [];

  final List processDataList = [
    {"id": 1, "data_type": 'Compost'},
    {"id": 2, "data_type": 'Rdf'},
    {"id": 3, "data_type": 'Recyclable'},
    {"id": 4, "data_type": 'Inerts'},
  ];

  final List distributeDataList = [
    {"id": 1, "data_type": 'CompostOutflow'},
    {"id": 2, "data_type": 'RdfOutflow'},
    {"id": 3, "data_type": 'RecyclableOutflow'},
    {"id": 4, "data_type": 'InertsOutflow'},
  ];

  final CarouselController carouselController = CarouselController();
  final CarouselController siteSbuCarouselController = CarouselController();

  String roles = "";

  double totalCollectionQuantity = 0.0;
  double totalProcessQuantity = 0.0;

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
    getConnectivity();
    _homeTabController = TabController(
        vsync: this,
        length: 3); // myTabs.length change it with number of tabs you have
    super.initState();
  }

  initSiteCall() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    roles = widget.userRole;
    _irisHomeScreenDataListRequestModel = CollectionDataListRequestModel();

    selectedSBU = widget.sbuCode;
    prefs.setString("selectSBU", widget.sbuCode);

    getRoleName();
    irisHomeRequestModel = IRISHomeRequestModel();
    GetIRISHomeAPIService getIRISHomeAPIService = GetIRISHomeAPIService();
    getIRISHomeAPIService.getIrisHomeApiCall(irisHomeRequestModel);
    _mswProcessingDataListRequestModel = MswProcessingDataListRequestModel();
    _mswDistributeDataListRequestModel = MswDistributeDataListRequestModel();

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
    debugPrint("................$_siteID");
    GetMswCollectionDataListAPIService getMswCollectionDataListAPIService =
        GetMswCollectionDataListAPIService();
    getMswCollectionDataListAPIService.getMswCollectionDataListApiCall(
        _irisHomeScreenDataListRequestModel,
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.start),
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.end),
        _siteID);

    prefs.setString("site", _siteID);

    GetMswPndDataListAPIService getMswPndDataListApiCall =
        GetMswPndDataListAPIService();
    getMswPndDataListApiCall.getMswPndDataListApiCall(
        _mswProcessingDataListRequestModel,
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.start),
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.end),
        _siteID);

    GetMswDistributeDataListAPIService getMswDistributeDataListApiCall =
        GetMswDistributeDataListAPIService();
    getMswDistributeDataListApiCall.getMswDistributeDataListApiCall(
        _mswDistributeDataListRequestModel,
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.start),
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.end),
        _siteID);
  }

  @override
  void dispose() {
    _homeTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('az');
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: kWhite,
        body: operatorHeadHomeScreen(context),
      ),
    );
  }

  Widget _tabSection(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0, left: 10.0),
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
                        child: Text('Collection',
                            style: TextStyle(
                                fontSize: 13.0,
                                color: kColorBlack,
                                fontWeight: FontWeight.w500))),
                  ),
                  Tab(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text('Processing',
                            style: TextStyle(
                                fontSize: 13.0,
                                color: kColorBlack,
                                fontWeight: FontWeight.w500))),
                  ),
                  Tab(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text('Distribution',
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
                      collectionTab(),
                      processingTab(),
                      distributionTab()
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

  Future<String> getRoleName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return MySharedPreferences.instance.getStringValue('IRIS_ROLE_NAME');
  }

  Widget operatorHeadHomeScreen(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          widget.userRole.contains("MSW-Sitehead")
              ? const SizedBox(
                  height: 10.0,
                )
              : const SizedBox(),
          widget.userRole.contains("MSW-Sitehead")
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
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
            child: Row(
              children: [
                widget.userRole.contains("MSW-Sbuhead") == false
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
                widget.userRole.contains("MSW-Sbuhead")
                    ? Expanded(
                        flex: 3,
                        child: Container(
                            alignment: Alignment.centerLeft,
                            height: 35,
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
                                    fontSize: 14.0,
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
                widget.userRole.contains("MSW-Sbuhead")
                    ? ValueListenableBuilder(
                        valueListenable: siteDataListValueNotifier,
                        builder: (BuildContext ctx,
                            List<SiteDataListResponseModel> dataList,
                            Widget? child) {
                          if (dataList.isNotEmpty) {
                            return Expanded(
                              flex: 2,
                              child: DropdownButtonHideUnderline(
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
                              ),
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      )
                    : const SizedBox(),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          _tabSection(context),
        ],
      ),
    );
  }

  Widget collectionTab() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: ValueListenableBuilder(
        valueListenable: mswCollectionDataListValueNotifier,
        builder: (BuildContext ctx,
            List<CollectionDataListResponseModel> collectionDataList,
            Widget? child) {
          if (collectionDataList.isNotEmpty) {
            collectionList.clear();
            collectionDataList
                .sort((b, a) => a.collectionDate!.compareTo(b.collectionDate!));
            for (CollectionDataListResponseModel data in collectionDataList) {
              if (collectionList.length < 5) {
                collectionList.add(OrdinalData(
                    domain: data.collectionDate!.split("-")[2],
                    measure: double.parse(data.collectionQty.toString()),
                    color: kReSustainabilityRed));
              }
            }

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  widget.userRole.contains("MSW-Sitehead") ||
                          widget.userRole.contains("MSW-Sbuhead")
                      ? CollectSummary(
                          wasteCollected: totalCollectionQuantity,
                          wasteProcessed: totalProcessQuantity,
                        )
                      : const SizedBox(),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
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
                        height: MediaQuery.of(context).size.height * 0.37,
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
                                  height: 35.0,
                                  child: Row(children: [
                                    const Text("Collection Trend",
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: kColorBlack)),
                                    const Spacer(),
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
                                                fontSize: 12.0,
                                                color: kColorBlack)),
                                      ),
                                    )
                                  ]),
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.26,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 5.0,
                                      left: 25.0,
                                      top: 10.0,
                                      bottom: 10.0),
                                  child: DChartBarO(
                                    barLabelValue: (group, ordinalData, index) {
                                      return ordinalData.measure
                                          .round()
                                          .toString();
                                    },
                                    outsideBarLabelStyle:
                                        (group, ordinalData, index) {
                                      return const LabelStyle(
                                        fontSize: 9,
                                        color: kColorBlack,
                                      );
                                    },
                                    barLabelDecorator: BarLabelDecorator(
                                      barLabelPosition:
                                          BarLabelPosition.outside,
                                    ),
                                    configRenderBar: ConfigRenderBar(
                                      barGroupInnerPaddingPx: 2,
                                      barGroupingType: BarGroupingType.grouped,
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
                                        data: collectionList,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Align(
                                alignment: Alignment.topCenter,
                                child: Text("Date",
                                    style: TextStyle(
                                        fontSize: 12.0, color: kColorBlack)),
                              )
                            ],
                          ),
                        )),
                  ),
                  const SizedBox(height: 5.0),
                  widget.userRole.contains("MSW-Sitehead") ||
                          widget.userRole.contains("MSW-Sbuhead")
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
                                            child: Text("Weight\n(MT)",
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
                                            collectionDataList.take(10).length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return collectionCard(
                                              collectionDataList[index]);
                                        }),
                                  ],
                                )),
                          ),
                        ),
                  widget.userRole.contains("MSW-Sitehead") ||
                          widget.userRole.contains("MSW-Sbuhead")
                      ? FutureBuilder<String>(
                          future: getData(),
                          builder: (context, snapshot) {
                            if (snapshot.data == "") {
                              return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
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
                                  height:
                                      MediaQuery.of(context).size.height * 0.43,
                                  child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            top: 15.0, left: 15.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Recyclable Waste",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: AspectRatio(
                                          aspectRatio: 13 / 9,
                                          child: Stack(
                                            children: [
                                              DChartPieO(
                                                data: ordinalDataList,
                                                configRenderPie:
                                                    const ConfigRenderPie(
                                                  arcWidth: 30,
                                                ),
                                              ),
                                              const Positioned(
                                                child: Center(
                                                    child: Text(
                                                  "MSW Trends",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                )),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 10.0,
                                            left: 10.0,
                                            bottom: 10.0,
                                            top: 10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            ClipOval(
                                              child: Container(
                                                height: 15,
                                                width: 15,
                                                color: kGreenDotColor,
                                              ),
                                            ),
                                            ValueListenableBuilder(
                                              valueListenable:
                                                  mswCollectionDataListValueNotifier,
                                              builder: (context,
                                                  List<CollectionDataListResponseModel>
                                                      collectionDataList,
                                                  child) {
                                                if (collectionDataList
                                                    .isNotEmpty) {
                                                  return Text(
                                                      "Total Collection - ${collectionDataList[0].qtySum} MT",
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 10,
                                                          fontFamily: 'Poppins',
                                                          fontWeight:
                                                              FontWeight.w500));
                                                } else {
                                                  return const Text(
                                                      "Total Collection - 0.0 MT",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 10,
                                                          fontFamily: 'Poppins',
                                                          fontWeight:
                                                              FontWeight.w500));
                                                }
                                              },
                                            ),
                                            const SizedBox(width: 3.0),
                                            ClipOval(
                                              child: Container(
                                                height: 15,
                                                width: 15,
                                                color: kYellowDotColor,
                                              ),
                                            ),
                                            const SizedBox(width: 2.0),
                                            ValueListenableBuilder(
                                              valueListenable:
                                                  mswProcessingDataListValueNotifier,
                                              builder: (context,
                                                  List<MswProcessDataListResponseModel>
                                                      processingDataList,
                                                  child) {
                                                if (processingDataList
                                                    .isNotEmpty) {
                                                  return Text(
                                                      "Total Processed - ${processingDataList[0].qtySum} MT",
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 10,
                                                          fontFamily: 'Poppins',
                                                          fontWeight:
                                                              FontWeight.w500));
                                                } else {
                                                  return const Text(
                                                      "Total Processed - 0.0 MT",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 10,
                                                          fontFamily: 'Poppins',
                                                          fontWeight:
                                                              FontWeight.w500));
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        )
                      : const SizedBox(),
                  SizedBox(
                    height: Platform.isIOS ? 40.h : 35.h,
                  ),
                ],
              ),
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
    );
  }

  Widget collectionCard(
      CollectionDataListResponseModel collectionDataListResponseModel) {
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
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(
                      collectionDataListResponseModel.collectionDate!)),
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
                  padding: const EdgeInsets.only(right: 70.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatNumber(double.tryParse(collectionDataListResponseModel
                              .collectionQty.toString())!),
                      textAlign: TextAlign.center,
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

  Widget processingTab() {
    return ListView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ValueListenableBuilder(
            valueListenable: mswProcessingDataListValueNotifier,
            builder: (BuildContext ctx,
                List<MswProcessDataListResponseModel> processingDataList,
                Widget? child) {
              if (processingDataList.isNotEmpty) {
                processingDataList.sort((b, a) => a.date.compareTo(b.date));

                return Column(
                  children: [
                    widget.userRole.contains("MSW-Sitehead") ||
                            widget.userRole.contains("MSW-Sbuhead")
                        ? ProcessingSummary(
                            wasteCollected: totalCollectionQuantity,
                            wasteProcessed: totalProcessQuantity)
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
                          items: processDataList
                              .map(
                                (item) => processCarouselContent(
                                    item["data_type"], processingDataList),
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
                      children: processDataList.asMap().entries.map((entry) {
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
                    widget.userRole.contains("MSW-Sitehead") ||
                            widget.userRole.contains("MSW-Sbuhead")
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
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
                                      padding: EdgeInsets.all(10.0),
                                      child: Row(children: [
                                        Expanded(
                                            child: Text("Date",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        Expanded(
                                            child: Text("Compost \n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        Expanded(
                                            child: Text("RDF \n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        Expanded(
                                            child: Text("Recyclables \n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        Expanded(
                                            child: Text("Inerts \n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                      ]),
                                    ),
                                    ListView.builder(
                                        shrinkWrap: true, // <- added
                                        physics: const ClampingScrollPhysics(),
                                        itemCount:
                                            processingDataList.take(10).length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return processingCard(
                                              processingDataList[index]);
                                        }),
                                  ],
                                )),
                          ),
                    SizedBox(
                      height: 2.h,
                    ),
                    widget.userRole.contains("MSW-Sitehead") ||
                            widget.userRole.contains("MSW-Sbuhead")
                        ? FutureBuilder<String>(
                            future: getData(),
                            builder: (context, snapshot) {
                              if (snapshot.data == "") {
                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 1,
                                          offset: const Offset(0,
                                              1), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    height: MediaQuery.of(context).size.height *
                                        0.43,
                                    child: Column(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              top: 15.0, left: 15.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Recyclable Waste",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: AspectRatio(
                                            aspectRatio: 13 / 9,
                                            child: Stack(
                                              children: [
                                                DChartPieO(
                                                  data: ordinalDataList,
                                                  configRenderPie:
                                                      const ConfigRenderPie(
                                                    arcWidth: 30,
                                                  ),
                                                ),
                                                const Positioned(
                                                  child: Center(
                                                      child: Text(
                                                    "MSW Trends",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w900),
                                                  )),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0,
                                              left: 10.0,
                                              bottom: 10.0,
                                              top: 10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ClipOval(
                                                child: Container(
                                                  height: 15,
                                                  width: 15,
                                                  color: kGreenDotColor,
                                                ),
                                              ),
                                              ValueListenableBuilder(
                                                valueListenable:
                                                    mswCollectionDataListValueNotifier,
                                                builder: (context,
                                                    List<CollectionDataListResponseModel>
                                                        collectionDataList,
                                                    child) {
                                                  if (collectionDataList
                                                      .isNotEmpty) {
                                                    return Text(
                                                        "Total Collection - ${collectionDataList[0].qtySum} MT",
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500));
                                                  } else {
                                                    return const Text(
                                                        "Total Collection - 0.0 MT",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500));
                                                  }
                                                },
                                              ),
                                              const SizedBox(width: 3.0),
                                              ClipOval(
                                                child: Container(
                                                  height: 15,
                                                  width: 15,
                                                  color: kYellowDotColor,
                                                ),
                                              ),
                                              const SizedBox(width: 2.0),
                                              ValueListenableBuilder(
                                                valueListenable:
                                                    mswProcessingDataListValueNotifier,
                                                builder: (context,
                                                    List<MswProcessDataListResponseModel>
                                                        processingDataList,
                                                    child) {
                                                  if (processingDataList
                                                      .isNotEmpty) {
                                                    return Text(
                                                        "Total Processed - ${processingDataList[0].qtySum} MT",
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500));
                                                  } else {
                                                    return const Text(
                                                        "Total Processed - 0.0 MT",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500));
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return const SizedBox();
                              }
                            })
                        : const SizedBox(),
                    SizedBox(
                      height: Platform.isIOS ? 40.h : 35.h,
                    )
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
                            "Its look like you have no Processing data to view",
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
                              "Once the Processing data is added by the user, the data will reflect here",
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

  Widget processingCard(
      MswProcessDataListResponseModel mswProcessDataListResponseModel) {
    return Container(
      width: double.infinity,
      color: kWhite,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0, left: 5.0),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  DateFormat('dd/MM/yyyy').format(
                      DateTime.parse(mswProcessDataListResponseModel.date)),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: kColorBlack,
                      fontSize: 9.5.sp,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400),
                )),
                Container(
                  height: 45.0,
                  width: 0.2,
                  color: kGreyTitleColor,
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                     formatNumber(double.tryParse(mswProcessDataListResponseModel.total_compost
                              .toString())!),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kColorBlack,
                          fontSize: 9.5.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                )),
                Container(
                  height: 45.0,
                  width: 0.2,
                  color: kGreyTitleColor,
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatNumber(double.tryParse(mswProcessDataListResponseModel.total_rdf
                              .toString())!),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kColorBlack,
                          fontSize: 9.5.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                )),
                Container(
                  height: 45.0,
                  width: 0.2,
                  color: kGreyTitleColor,
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatNumber(double.tryParse(mswProcessDataListResponseModel
                              .total_recylables
                              .toString())!),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kColorBlack,
                          fontSize: 9.5.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                )),
                Container(
                  height: 45.0,
                  width: 0.2,
                  color: kGreyTitleColor,
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatNumber(double.tryParse(mswProcessDataListResponseModel.total_inerts
                              .toString())!),
                      textAlign: TextAlign.center,
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

  Widget distributionTab() {
    return ListView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ValueListenableBuilder(
            valueListenable: mswDistributeDataListValueNotifier,
            builder: (BuildContext ctx,
                List<MswDistributeDataListResponseModel> distributionDataList,
                Widget? child) {
              if (distributionDataList.isNotEmpty) {
                distributionDataList.sort((b, a) => a.date.compareTo(b.date));
                ordinalDataList = [
                  OrdinalData(
                      domain: 'Total Collection',
                      measure: collectWasteSum,
                      color: kGreenDotColor),
                  OrdinalData(
                      domain: 'Total Processed',
                      measure: totalProcessQuantity,
                      color: kYellowDotColor),
                ];
                return Column(
                  children: [
                    widget.userRole.contains("MSW-Sitehead") ||
                            widget.userRole.contains("MSW-Sbuhead")
                        ? ProcessingSummary(
                            wasteCollected: totalCollectionQuantity,
                            wasteProcessed: totalProcessQuantity)
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
                          items: distributeDataList
                              .map(
                                (item) => distributeCarouselContent(
                                    item["data_type"], distributionDataList),
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
                      children: distributeDataList.asMap().entries.map((entry) {
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
                    widget.userRole.contains("MSW-Sitehead") ||
                            widget.userRole.contains("MSW-Sbuhead")
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
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
                                      padding: EdgeInsets.all(10.0),
                                      child: Row(children: [
                                        Expanded(
                                            child: Text("Date",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        Expanded(
                                            child: Text(
                                                "Compost \nOutflow \n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        Expanded(
                                            child: Text("RDF \nOutflow \n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        Expanded(
                                            child: Text(
                                                "Recyclables \nOutflow \n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                        Expanded(
                                            child: Text(
                                                "Inerts \nOutflow \n(MT)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: kGreyTitleColor))),
                                      ]),
                                    ),
                                    ListView.builder(
                                        shrinkWrap: true, // <- added
                                        physics: const ClampingScrollPhysics(),
                                        itemCount: distributionDataList
                                            .take(10)
                                            .length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return distributionCard(
                                              distributionDataList[index]);
                                        }),
                                  ],
                                )),
                          ),
                    SizedBox(
                      height: 2.h,
                    ),
                    widget.userRole.contains("MSW-Sitehead") ||
                            widget.userRole.contains("MSW-Sbuhead")
                        ? FutureBuilder<String>(
                            future: getData(),
                            builder: (context, snapshot) {
                              if (snapshot.data == "") {
                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 1,
                                          offset: const Offset(0,
                                              1), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    height: MediaQuery.of(context).size.height *
                                        0.43,
                                    child: Column(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              top: 15.0, left: 15.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Recyclable Waste",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: AspectRatio(
                                            aspectRatio: 13 / 9,
                                            child: Stack(
                                              children: [
                                                DChartPieO(
                                                  data: ordinalDataList,
                                                  configRenderPie:
                                                      const ConfigRenderPie(
                                                    arcWidth: 30,
                                                  ),
                                                ),
                                                const Positioned(
                                                  child: Center(
                                                      child: Text(
                                                    "MSW Trends",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w900),
                                                  )),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0,
                                              left: 10.0,
                                              bottom: 10.0,
                                              top: 10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ClipOval(
                                                child: Container(
                                                  height: 15,
                                                  width: 15,
                                                  color: kGreenDotColor,
                                                ),
                                              ),
                                              const SizedBox(width: 2.0),
                                              ValueListenableBuilder(
                                                valueListenable:
                                                    mswCollectionDataListValueNotifier,
                                                builder: (context,
                                                    List<CollectionDataListResponseModel>
                                                        collectionDataList,
                                                    child) {
                                                  if (collectionDataList
                                                      .isNotEmpty) {
                                                    return Text(
                                                        "Total Collection - ${collectionDataList[0].qtySum} MT",
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500));
                                                  } else {
                                                    return const Text(
                                                        "Total Collection - 0.0 MT",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500));
                                                  }
                                                },
                                              ),
                                              const SizedBox(width: 3.0),
                                              ClipOval(
                                                child: Container(
                                                  height: 15,
                                                  width: 15,
                                                  color: kYellowDotColor,
                                                ),
                                              ),
                                              const SizedBox(width: 2.0),
                                              ValueListenableBuilder(
                                                valueListenable:
                                                    mswProcessingDataListValueNotifier,
                                                builder: (context,
                                                    List<MswProcessDataListResponseModel>
                                                        processingDataList,
                                                    child) {
                                                  if (processingDataList
                                                      .isNotEmpty) {
                                                    return Text(
                                                        "Total Processed - ${processingDataList[0].qtySum} MT",
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500));
                                                  } else {
                                                    return const Text(
                                                        "Total Processed - 0.0 MT",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500));
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return SizedBox();
                              }
                            })
                        : const SizedBox(),
                    SizedBox(
                      height: Platform.isIOS ? 40.h : 35.h,
                    )
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
                            "Its look like you have no Distribution data to view",
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
                              "Once the Distribution data is added by the user, the data will reflect here",
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

  Widget distributionCard(
      MswDistributeDataListResponseModel mswDistributeDataListResponseModel) {
    return Container(
      width: double.infinity,
      color: kWhite,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0, left: 5.0),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  DateFormat('dd/MM/yyyy').format(
                      DateTime.parse(mswDistributeDataListResponseModel.date)),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: kColorBlack,
                      fontSize: 9.5.sp,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400),
                )),
                Container(
                  height: 45.0,
                  width: 0.2,
                  color: kGreyTitleColor,
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatNumber(double.tryParse(mswDistributeDataListResponseModel.compost
                              .toString())!),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kColorBlack,
                          fontSize: 9.5.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                )),
                Container(
                  height: 45.0,
                  width: 0.2,
                  color: kGreyTitleColor,
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatNumber(double.tryParse(
                              mswDistributeDataListResponseModel.rdf.toString())!),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kColorBlack,
                          fontSize: 9.5.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                )),
                Container(
                  height: 45.0,
                  width: 0.2,
                  color: kGreyTitleColor,
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatNumber(double.tryParse(mswDistributeDataListResponseModel
                              .recyclables
                              .toString())!),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kColorBlack,
                          fontSize: 9.5.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                )),
                Container(
                  height: 45.0,
                  width: 0.2,
                  color: kGreyTitleColor,
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatNumber(double.tryParse(mswDistributeDataListResponseModel.inserts
                              .toString())!),
                      textAlign: TextAlign.center,
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

  Widget processCarouselContent(
      String dataType, List<MswProcessDataListResponseModel> dataList) {
    if (dataType == "Compost") {
      if (dataList.isNotEmpty) {
        compostList.clear();
        for (MswProcessDataListResponseModel data in dataList) {
          if (compostList.length < 5) {
            compostList.add(OrdinalData(
                domain: data.date.split("-")[2],
                measure: double.parse(data.total_compost.toString()),
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
                          const Text("Processing Trend",
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
                                color: kRecycleBag,
                              )),
                              const SizedBox(width: 5.0),
                              const Text("Compost",
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
                          color: kRecycleBag,
                          data: compostList,
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
    } else if (dataType == "Rdf") {
      if (dataList.isNotEmpty) {
        rdfList.clear();
        for (MswProcessDataListResponseModel data in dataList) {
          if (rdfList.length < 5) {
            rdfList.add(OrdinalData(
                domain: data.date.split("-")[2],
                measure: double.parse(data.total_rdf.toString()),
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
                                Row(
                                  children: [
                                    ClipOval(
                                        child: Container(
                                      height: 15,
                                      width: 15,
                                      color: kRecycleGlass,
                                    )),
                                    const SizedBox(width: 5.0),
                                    const Text("RDF",
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
                                color: kRecycleGlass,
                                data: rdfList,
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
    } else if (dataType == "Recyclable") {
      if (dataList.isNotEmpty) {
        recyclablesList.clear();
        for (MswProcessDataListResponseModel data in dataList) {
          if (recyclablesList.length < 5) {
            recyclablesList.add(OrdinalData(
                domain: data.date.split("-")[2],
                measure: double.parse(data.total_recylables.toString()),
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
                          const Text("Processing Trend",
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
                                color: kRecycleCardboard,
                              )),
                              const SizedBox(width: 5.0),
                              const Text("Recyclables",
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
                          color: kRecycleCardboard,
                          data: recyclablesList,
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
      if (dataList.isNotEmpty) {
        inertsList.clear();
        for (MswProcessDataListResponseModel data in dataList) {
          if (inertsList.length < 5) {
            inertsList.add(OrdinalData(
                domain: data.date.split("-")[2],
                measure: double.parse(data.total_inerts.toString()),
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
                          const Text("Processing Trend",
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
                                color: kRecyclePlastic,
                              )),
                              const SizedBox(width: 5.0),
                              const Text("Inerts",
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
                          color: kRecyclePlastic,
                          data: inertsList,
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
    }
  }

  Widget distributeCarouselContent(
      String dataType, List<MswDistributeDataListResponseModel> dataList) {
    if (dataType == "CompostOutflow") {
      if (dataList.isNotEmpty) {
        compostOutflowList.clear();
        for (MswDistributeDataListResponseModel data in dataList) {
          if (compostOutflowList.length < 5) {
            compostOutflowList.add(OrdinalData(
                domain: data.date.split("-")[2],
                measure: double.parse(data.compost.toString()),
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
                          const Text("Distribution Trend",
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
                                color: kRecycleBag,
                              )),
                              const SizedBox(width: 5.0),
                              const Text("Compost \nOutflow",
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
                          color: kRecycleBag,
                          data: compostOutflowList,
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
    } else if (dataType == "RdfOutflow") {
      if (dataList.isNotEmpty) {
        rdfOutflowList.clear();
        for (MswDistributeDataListResponseModel data in dataList) {
          if (rdfOutflowList.length < 5) {
            rdfOutflowList.add(OrdinalData(
                domain: data.date.split("-")[2],
                measure: double.parse(data.rdf.toString()),
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
                                const Text("Distribution Trend",
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
                                      color: kRecycleGlass,
                                    )),
                                    const SizedBox(width: 5.0),
                                    const Text("RDF \nOutflow",
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
                                color: kRecycleGlass,
                                data: rdfOutflowList,
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
    } else if (dataType == "RecyclableOutflow") {
      if (dataList.isNotEmpty) {
        recyclablesOutflowList.clear();
        for (MswDistributeDataListResponseModel data in dataList) {
          if (recyclablesOutflowList.length < 5) {
            recyclablesOutflowList.add(OrdinalData(
                domain: data.date.split("-")[2],
                measure: double.parse(data.recyclables.toString()),
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
                          const Text("Distribution Trend",
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
                                color: kRecycleCardboard,
                              )),
                              const SizedBox(width: 5.0),
                              const Text("Recyclables \nOutflow",
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
                          color: kRecycleCardboard,
                          data: recyclablesOutflowList,
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
      if (dataList.isNotEmpty) {
        inertsOutflowList.clear();
        for (MswDistributeDataListResponseModel data in dataList) {
          if (inertsOutflowList.length < 5) {
            inertsOutflowList.add(OrdinalData(
                domain: data.date.split("-")[2],
                measure: double.parse(data.inserts.toString()),
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
                          const Text("Distribution Trend",
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
                                color: kRecyclePlastic,
                              )),
                              const SizedBox(width: 5.0),
                              const Text("Inerts \nOutflow",
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
                          color: kRecyclePlastic,
                          data: inertsOutflowList,
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
    }
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
                    initSiteCall();
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
      initSiteCall();
    }
  }

  Future<String> getSiteID() {
    return MySharedPreferences.instance.getStringValue('IRIS_SITE_NAME');
  }

  Future<String> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    totalProcessQuantity = prefs.getDouble("mswProcessQty")!;
    totalCollectionQuantity = prefs.getDouble("qtyCollectionMswSum")!;
    ordinalDataList = [
      OrdinalData(
          domain: 'Total Collection',
          measure: totalCollectionQuantity,
          color: kGreenDotColor),
      OrdinalData(
          domain: 'Total Processed',
          measure: totalProcessQuantity,
          color: kYellowDotColor),
    ];

    return "";
  }
}
