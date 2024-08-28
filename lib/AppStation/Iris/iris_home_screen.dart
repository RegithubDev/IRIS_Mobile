import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:d_chart/d_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:resus_test/AppStation/Iris/Department_Screen.dart';
import 'package:resus_test/AppStation/Iris/api/get_collection_data_list_api_service.dart';
import 'package:resus_test/AppStation/Iris/api/get_site_list_api_service.dart';
import 'package:resus_test/AppStation/Iris/department/iwm_screen.dart';
import 'package:resus_test/AppStation/Iris/widgets/bmw_pie_chart.dart';
import 'package:resus_test/AppStation/Iris/widgets/bmw_summary.dart';
import 'package:resus_test/AppStation/Iris/model/processing_data_list_model.dart';
import 'package:resus_test/AppStation/Iris/model/recyclable_data_list_model.dart';
import 'package:resus_test/AppStation/Iris/msw_operaton_head_screens/c_&_t_collect_form.dart';
import 'package:resus_test/AppStation/Iris/widgets/scroll_chart_site_sbu.dart';
import 'package:resus_test/AppStation/Iris/department/Wte_screen.dart';
import 'package:resus_test/AppStation/Iris/widgets/waste%20_summary.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../Screens/home/home.dart';
import '../../Utility/MySharedPreferences.dart';
import '../../Utility/shared_preferences_string.dart';
import '../../Utility/showLoader.dart';
import '../../Utility/utils/constants.dart';
import '../../custom_sharedPreference.dart';
import 'Collect/collect_screen.dart';
import 'Distribute/distribute_screen.dart';
import 'Iris_Profile/iris_profile_screen.dart';
import 'Processing/processing_screen.dart';
import 'api/get_iris_home_api_service.dart';
import 'api/get_processing_data_list_api_service.dart';
import 'api/get_recyclable_data_list_api_service.dart';
import 'api/get_roles_api_service.dart';
import 'model/collection_data_list_model.dart';
import 'model/iris_home_model.dart';
import 'model/site_data_list_model.dart';
import 'model/user_roles_model.dart';
import 'msw_operaton_head_screens/c_&_t_home.dart';
import 'msw_operaton_head_screens/msw_process_distribute_form.dart';

class IrisHomeScreen extends StatefulWidget {
  final String sbuCode;
  final String userRole;
  final String departmentName;
  IrisHomeScreen(
      {super.key,
      required this.sbuCode,
      required this.userRole,
      required this.departmentName});

  @override
  State<IrisHomeScreen> createState() => _IrisHomeScreenState();
}

class _IrisHomeScreenState extends State<IrisHomeScreen>
    with SingleTickerProviderStateMixin {
  late IRISHomeRequestModel irisHomeRequestModel;
  UserRoleRequestModel userRoleRequestModel = UserRoleRequestModel();
  DateRange? selectedDateRange;

  SiteDataListResponseModel sites = SiteDataListResponseModel();
  late SharedPreferences prefs;
  late List<SiteDataListResponseModel> collectionDataList;

  GoogleSignInAccount? m_googleSignInAccount;
  String m_user_id = "";
  String m_emailId = "";

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  late TextEditingController dateInputController = TextEditingController();
  late TextEditingController sbuController = TextEditingController();
  late TabController tabController, _homeTabController;

  int currentIndex = 0;
  int scrollIndex = 0;
  int recycleIndex = 0;
  int _selectedIndex = -1;
  String _siteID = "";
  bool isDateSelect = false;

  String roleName = "";

  late CollectionDataListRequestModel _irisHomeScreenDataListRequestModel;
  late ProcessingDataListRequestModel _processingDataListRequestModel;
  late RecyclableDataListRequestModel _recyclableDataListRequestModel;
  late SiteDataListRequestModel _siteDataListRequestModel;
  List<OrdinalData> ordinalDataList = [];

  Future<String> getSBUCode() {
    return MySharedPreferences.instance.getStringValue('IRIS_SBU_CODE');
  }

  List<OrdinalData> collectionList = [];

  String selectedSBU = "";
  String department = "";
  var sbuList = ['ALL', 'BMW', 'MSW'];
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 100)),
    end: DateTime.now(),
  );

  late DateTimeRange? newDateRange;
  String _selectedSite = "";
  List<OrdinalData> incinerationList = [];
  List<OrdinalData> autoclaveList = [];
  List<OrdinalData> recyclableList = [];
  List<OrdinalData> processingList = [];
  List<OrdinalData> bagList = [];
  List<OrdinalData> glassList = [];
  List<OrdinalData> cardBoardList = [];
  List<OrdinalData> plasticList = [];

  final List dataList = [
    {"id": 1, "data_type": 'Bag'},
    {"id": 2, "data_type": 'Glass'},
    {"id": 3, "data_type": 'CardBoard'},
    {"id": 4, "data_type": 'Plastics'},
  ];

  final List chartDataSiteHead = [
    {"id": 1, "data_type": 'collection'},
    {"id": 2, "data_type": 'processing'},
    {"id": 3, "data_type": 'recyclable'}
  ];
  final CarouselController carouselController = CarouselController();
  final CarouselController siteSbuCarouselController = CarouselController();

  String roles = "";

  double totalQuantity = 0.0;
  double totalIncineration = 0.0;
  double totalAutoClave = 0.0;
  double totalRecyclables = 0.0;

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
    _irisHomeScreenDataListRequestModel = CollectionDataListRequestModel();
    _processingDataListRequestModel = ProcessingDataListRequestModel();
    _recyclableDataListRequestModel = RecyclableDataListRequestModel();
    _siteDataListRequestModel = SiteDataListRequestModel();

    selectedSBU = widget.sbuCode;
    department = widget.departmentName;
    prefs = await SharedPreferences.getInstance();
    prefs.setString("selectSBU", widget.sbuCode);
    prefs.setString("department", widget.departmentName);

    roleName = widget.userRole;
    GetSiteListAPIService getSiteListAPIService = GetSiteListAPIService();
    await getSiteListAPIService.getSiteListApiCall(
        _siteDataListRequestModel, selectedSBU);
    GetUserRoleAPIService getUserRoleAPIService = GetUserRoleAPIService();
    await getUserRoleAPIService.getUserRoleApiCall(
        userRoleRequestModel, selectedSBU);
    debugPrint(roleName);
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

    getRoleName();
    irisHomeRequestModel = IRISHomeRequestModel();
    GetIRISHomeAPIService getIRISHomeAPIService = GetIRISHomeAPIService();
    getIRISHomeAPIService.getIrisHomeApiCall(irisHomeRequestModel);

    debugPrint("!!!!!!!!!!!!!!!!$_siteID");
    prefs.setString("site", _siteID);
    GetCollectionDataListAPIService getCollectionDataListAPIService =
        GetCollectionDataListAPIService();
    getCollectionDataListAPIService.getCollectionDataListApiCall(
        _irisHomeScreenDataListRequestModel,
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.start),
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.end),
        _siteID);

    GetProcessingDataListAPIService getProcessingDataListAPIService =
        GetProcessingDataListAPIService();
    getProcessingDataListAPIService.getProcessingDataListApiCall(
        _processingDataListRequestModel,
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.start),
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.end),
        selectedSBU,
        _siteID);

    GetRecyclableDataListAPIService getRecyclableDataListAPIService =
        GetRecyclableDataListAPIService();
    getRecyclableDataListAPIService.getRecyclableDataListApiCall(
        _recyclableDataListRequestModel,
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.start),
        dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.end),
        selectedSBU,
        _siteID);
  }

  @override
  Widget build(BuildContext context) {
    department = widget.departmentName;
    initializeDateFormatting('az');
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        _showBackDialog().then((value) {
          if (value != null && value) {
            // Navigator.of(context).pop();
          }
        });
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: kWhite,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
            child: AppBar(
              centerTitle: true,
              title: Text(
                widget.departmentName,
                style: const TextStyle(
                    fontFamily: "ARIAL",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              leading: InkWell(
                  onTap: () async {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DepartmentScreen()));
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Icon(Icons.arrow_back_ios),
                  )),
              elevation: 0,
              backgroundColor: kReSustainabilityRed,
              actions: [
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Image.asset(
                      "assets/icons/home.png",
                      height: 25.0,
                      width: 25.0,
                    ),
                  ),
                  onTap: () async {
                    String userId = await CustomSharedPref.getPref<String>(
                            SharedPreferencesString.userId) ??
                        '';
                    String emailId = await CustomSharedPref.getPref<String>(
                            SharedPreferencesString.emailId) ??
                        '';
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Home(
                                googleSignInAccount: null,
                                userId: userId,
                                emailId: emailId,
                                initialSelectedIndex: 0)));
                  },
                ),
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Image.asset(
                      "assets/icons/user.png",
                      height: 25.0,
                      width: 25.0,
                    ),
                  ),
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const IrisProfileScreen();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          body: ValueListenableBuilder(
              valueListenable: userRoleValueNotifier,
              builder: (BuildContext ctx, String userRole, Widget? child) {
                if (roleName.contains("WTE") && department == "WTE") {
                  return WteScreen(
                      selectSBU: prefs.getString("selectSBU").toString(),
                      roles: roleName);
                } else if (roleName.contains("MSW-Sitehead") &&
                    department == "WTE") {
                  return WteScreen(
                      selectSBU: prefs.getString("selectSBU").toString(),
                      roles: roleName);
                } else if (roleName.contains("MSW-Sbuhead") &&
                    department == "WTE") {
                  return WteScreen(
                      selectSBU: prefs.getString("selectSBU").toString(),
                      roles: roleName);
                } else if (roleName.contains("Ops Head") &&
                    department == "BMW") {
                  return operatorHeadHomeScreen(context);
                } else if (roleName.contains("BMW-SiteHead") &&
                    department == "BMW") {
                  return siteHeadHomeScreen(context);
                } else if (roleName.contains("BMW-SBUHead") &&
                    department == "BMW") {
                  return sbuHeadHomeScreen(context);
                } else if (roleName.contains("CNT") ||
                    roleName.contains("PND") && department == "MSW") {
                  return CAndTHomeScreen(sbuCode: "MSW", userRole: roleName);
                } else if (roleName.contains("MSW-Sbuhead") &&
                    department == "MSW") {
                  return CAndTHomeScreen(sbuCode: "MSW", userRole: roleName);
                } else if (roleName.contains("MSW-Sitehead") &&
                    department == "MSW") {
                  return CAndTHomeScreen(sbuCode: "MSW", userRole: roleName);
                } else if (roleName.contains("Ops Head") &&
                    department == "IWM") {
                  return IWMScreen(
                      selectSBU: prefs.getString("selectSBU").toString(),
                      roles: roleName);
                } else if (roleName.contains("SiteHead") &&
                    department == "IWM") {
                  return IWMScreen(
                      selectSBU: prefs.getString("selectSBU").toString(),
                      roles: roleName);
                } else if (roleName.contains("SBUHead") &&
                    department == "IWM") {
                  return IWMScreen(
                      selectSBU: prefs.getString("selectSBU").toString(),
                      roles: roleName);
                } else {
                  return ShowLoader();
                }
              }),
          bottomNavigationBar: ValueListenableBuilder(
            valueListenable: userRoleValueNotifier,
            builder: (BuildContext ctx, String userRole, Widget? child) {
              if (roleName.contains('BMW-Site Ops Head') &&
                  department == "BMW") {
                return BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  selectedLabelStyle: const TextStyle(
                      fontSize: 12.0,
                      fontFamily: "ARIAL",
                      color: kWhite,
                      fontWeight: FontWeight.normal),
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 12.0,
                      fontFamily: "ARIAL",
                      color: kWhite,
                      fontWeight: FontWeight.normal),
                  backgroundColor: kReSustainabilityRed,
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: SizedBox(
                          width: 46,
                          height: 46,
                          child: SvgPicture.asset(
                            "assets/icons/collect.svg",
                            fit: BoxFit.cover,
                          )),
                      label: "Collect",
                    ),
                    BottomNavigationBarItem(
                      icon: SizedBox(
                        width: 46,
                        height: 46,
                        child: SvgPicture.asset("assets/icons/processing.svg",
                            fit: BoxFit.cover),
                      ),
                      label: "Processing",
                    ),
                    BottomNavigationBarItem(
                      icon: SizedBox(
                        width: 46,
                        height: 46,
                        child: SvgPicture.asset("assets/icons/distribute.svg",
                            fit: BoxFit.cover),
                      ),
                      label: "Distribute",
                    ),
                  ],
                  currentIndex: _selectedIndex == -1 ? 0 : _selectedIndex,
                  selectedItemColor: _selectedIndex == -1 ? kWhite : kWhite,
                  unselectedItemColor: kWhite,
                  onTap: _onItemTapped,
                );
              } else if (roleName.contains('CNT') && department == "MSW") {
                return Container(
                  height: Platform.isIOS ? 85 : 70,
                  color: kReSustainabilityRed,
                  child: Center(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CAndTCollectScreen(
                                wasteType: selectedSBU, siteID: _siteID),
                          )),
                          child: SizedBox(
                              height: 60,
                              width: 60,
                              child: SvgPicture.asset(
                                "assets/icons/collect.svg",
                                fit: BoxFit.cover,
                              )),
                        ),
                        Text(
                          "Collect",
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
                );
              } else if (roleName.contains('PND') && department == "MSW") {
                return Container(
                  height: Platform.isIOS ? 85 : 70,
                  color: kReSustainabilityRed,
                  child: Center(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const MSWPAndDScreen(),
                          )),
                          child: SizedBox(
                              height: 60,
                              width: 60,
                              child: SvgPicture.asset(
                                "assets/icons/distribute.svg",
                                fit: BoxFit.cover,
                              )),
                        ),
                        Text(
                          "P & D",
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
                );
              } else if (userRole == "BMW-SiteHead") {
                return const SizedBox();
              } else if (userRole == "BMW-SBUHead") {
                return const SizedBox();
              } else {
                return const SizedBox();
              }
            },
          )),
    );
  }

  Future<bool?> _showBackDialog() {
    return showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: const Text('Please confirm',
                style: TextStyle(
                  color: kReSustainabilityRed,
                  fontFamily: "ARIAL",
                )),
            content: const Text('Do you want go back? to Department Screen!',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "ARIAL",
                )),
            actions: <Widget>[
              TextButton(
                child: const Text('No',
                    style: TextStyle(
                      color: kReSustainabilityRed,
                      fontFamily: "ARIAL",
                    )),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                onPressed: () => {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DepartmentScreen()),
                  ),
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    color: kReSustainabilityRed,
                    fontFamily: "ARIAL",
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
                        child: Text('Recyclable',
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
                      recyclableTab()
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return CollectScreen(
              wasteType: selectedSBU,
              siteID: _siteID,
            );
          },
        ),
      );
    }
    if (_selectedIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ProcessingScreen(wasteType: selectedSBU, siteID: _siteID);
          },
        ),
      );
    }
    if (_selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return DistributeScreen(wasteType: selectedSBU, siteID: _siteID);
          },
        ),
      );
    }
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
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
            child: Row(
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    width: 230,
                    height: 35,
                    child: TextField(
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 33,
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
                        })),
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

  Widget siteHeadHomeScreen(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(
          height: 10.0,
        ),
        FutureBuilder(
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
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                    alignment: Alignment.centerLeft,
                    height: 35,
                    child: TextField(
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 30,
                            fontFamily: "ARIAL",
                            color: Colors.black),
                        textAlign: TextAlign.left,
                        readOnly: true,
                        controller: dateInputController,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.only(top: 10, left: 20.0),
                          hintText: "Select Date",
                          hintStyle: const TextStyle(
                              fontSize: 14.0,
                              fontFamily: "ARIAL",
                              color: Colors.black),
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
              ),
              const Spacer(),
            ],
          ),
        ),
        const SizedBox(height: 5.0),
        //For Waste Summary
        const WasteSummary(),
        const SizedBox(height: 5.0),
        ValueListenableBuilder(
          valueListenable: collectionDataListValueNotifier,
          builder: (context,
              List<CollectionDataListResponseModel> collectionDataList, child) {
            if (collectionDataList.isNotEmpty) {
              return const ScrollChart();
            } else {
              return ValueListenableBuilder(
                  valueListenable: processingDataListValueNotifier,
                  builder: (context,
                      List<ProcessingDataListResponseModel> processingDataList,
                      child) {
                    if (processingDataList.isNotEmpty) {
                      return const ScrollChart();
                    } else {
                      return ValueListenableBuilder(
                          valueListenable: recyclableDataListValueNotifier,
                          builder: (context,
                              List<RecyclableDataListResponseModel>
                                  recyclableDataList,
                              child) {
                            if (recyclableDataList.isNotEmpty) {
                              return const ScrollChart();
                            } else {
                              return Column(children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 9,
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
                          });
                    }
                  });
            }
          },
        ),
        const SizedBox(height: 10.0),
        ValueListenableBuilder(
          valueListenable: collectionDataListValueNotifier,
          builder: (context,
              List<CollectionDataListResponseModel> collectionDataList, child) {
            if (collectionDataList.isNotEmpty) {
              return BmwPieChart(
                totalIncineration: totalIncineration,
                totalQuantity: totalQuantity,
                totalAutoclave: totalAutoClave,
                totalRecyclable: totalRecyclables,
              );
            } else {
              return ValueListenableBuilder(
                  valueListenable: processingDataListValueNotifier,
                  builder: (context,
                      List<ProcessingDataListResponseModel> processingDataList,
                      child) {
                    if (processingDataList.isNotEmpty) {
                      return BmwPieChart(
                        totalIncineration: totalIncineration,
                        totalQuantity: totalQuantity,
                        totalAutoclave: totalAutoClave,
                        totalRecyclable: totalRecyclables,
                      );
                    } else {
                      return ValueListenableBuilder(
                          valueListenable: recyclableDataListValueNotifier,
                          builder: (context,
                              List<RecyclableDataListResponseModel>
                                  recyclableDataList,
                              child) {
                            if (recyclableDataList.isNotEmpty) {
                              return BmwPieChart(
                                totalIncineration: totalIncineration,
                                totalQuantity: totalQuantity,
                                totalAutoclave: totalAutoClave,
                                totalRecyclable: totalRecyclables,
                              );
                            } else {
                              return const SizedBox();
                            }
                          });
                    }
                  });
            }
          },
        ),
        const BmwSummary(),
        Padding(
          padding: const EdgeInsets.only(
              left: 20.0, right: 20, bottom: 10, top: 10.0),
          child: ValueListenableBuilder(
              valueListenable: recyclableDataListValueNotifier,
              builder: (BuildContext ctx,
                  List<RecyclableDataListResponseModel> recyclableDataList,
                  Widget? child) {
                if (recyclableDataList.isNotEmpty) {
                  recyclableDataList.sort(
                      (b, a) => a.recyclableDate!.compareTo(b.recyclableDate!));
                  recyclableList.clear();
                  for (RecyclableDataListResponseModel data
                      in recyclableDataList) {
                    recyclableList.add(OrdinalData(
                        domain: data.recyclableDate!.split("-")[2],
                        measure: num.parse(data.recyclableQty!),
                        color: kReSustainabilityRed));
                  }
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.39,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset:
                              const Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: CarouselSlider(
                      items: dataList
                          .map(
                            (item) => carouselContent(
                                item["data_type"], recyclableDataList),
                          )
                          .toList(),
                      carouselController: carouselController,
                      options: CarouselOptions(
                        height: MediaQuery.of(context).size.height * 0.39,
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
                  );
                } else {
                  return const SizedBox();
                }
              }),
        ),
        ValueListenableBuilder(
            valueListenable: recyclableDataListValueNotifier,
            builder: (BuildContext ctx,
                List<RecyclableDataListResponseModel> recyclableDataList,
                Widget? child) {
              if (recyclableDataList.isNotEmpty) {
                recyclableDataList.sort(
                    (b, a) => a.recyclableDate!.compareTo(b.recyclableDate!));
                recyclableList.clear();
                for (RecyclableDataListResponseModel data
                    in recyclableDataList) {
                  recyclableList.add(OrdinalData(
                      domain: data.recyclableDate!.split("-")[2],
                      measure: num.parse(data.recyclableQty!),
                      color: kReSustainabilityRed));
                }
                return Column(
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: dataList.asMap().entries.map((entry) {
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
                  ],
                );
              } else {
                return const SizedBox();
              }
            }),
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }

  Widget sbuHeadHomeScreen(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                    alignment: Alignment.centerLeft,
                    height: 35,
                    child: TextField(
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 37,
                            fontFamily: "ARIAL",
                            color: Colors.black),
                        textAlign: TextAlign.left,
                        readOnly: true,
                        controller: dateInputController,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.only(top: 10, left: 20.0),
                          hintText: "Select Date",
                          hintStyle: const TextStyle(
                              fontSize: 13,
                              fontFamily: "ARIAL",
                              color: Colors.black),
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
              ),
              SizedBox(
                width: 3.w,
              ),
              Expanded(
                flex: 2,
                child: ValueListenableBuilder(
                  valueListenable: siteDataListValueNotifier,
                  builder: (BuildContext ctx,
                      List<SiteDataListResponseModel> dataList, Widget? child) {
                    if (dataList.isNotEmpty) {
                      return DropdownButtonHideUnderline(
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: kWhite, // Background color of the dropdown
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                                color: inactiveColor), // Border color
                          ),
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: DropdownButton<String>(
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors
                                      .grey, // Replace with your inactiveColor
                                ),
                                iconSize: 25.0,
                                style: const TextStyle(
                                    fontSize: 13.0,overflow: TextOverflow.ellipsis,
                                    color:
                                        Colors.black), // Replace with kColorBlack
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
                                items: dataList.map<DropdownMenuItem<String>>(
                                    (SiteDataListResponseModel value) {
                                  return DropdownMenuItem<String>(
                                    value: value.siteName,
                                    child: Text(
                                      value.siteName!,
                                      style: const TextStyle(
                                          fontSize: 16.0, color: Colors.black),
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
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5.0),
        //For Waste Summary
        ValueListenableBuilder(
          valueListenable: collectionDataListValueNotifier,
          builder: (context,
              List<CollectionDataListResponseModel> collectionDataList, child) {
            if (collectionDataList.isNotEmpty) {
              return const WasteSummary();
            } else {
              return ValueListenableBuilder(
                  valueListenable: processingDataListValueNotifier,
                  builder: (context,
                      List<ProcessingDataListResponseModel> processingDataList,
                      child) {
                    if (processingDataList.isNotEmpty) {
                      return const WasteSummary();
                    } else {
                      return const SizedBox();
                    }
                  });
            }
          },
        ),
        const SizedBox(height: 5.0),
        ValueListenableBuilder(
          valueListenable: collectionDataListValueNotifier,
          builder: (context,
              List<CollectionDataListResponseModel> collectionDataList, child) {
            if (collectionDataList.isNotEmpty) {
              return const ScrollChart();
            } else {
              return ValueListenableBuilder(
                  valueListenable: processingDataListValueNotifier,
                  builder: (context,
                      List<ProcessingDataListResponseModel> processingDataList,
                      child) {
                    if (processingDataList.isNotEmpty) {
                      return const ScrollChart();
                    } else {
                      return ValueListenableBuilder(
                          valueListenable: recyclableDataListValueNotifier,
                          builder: (context,
                              List<RecyclableDataListResponseModel>
                                  recyclableDataList,
                              child) {
                            if (recyclableDataList.isNotEmpty) {
                              return const ScrollChart();
                            } else {
                              return Column(children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 4,
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
                          });
                    }
                  });
            }
          },
        ),

        ValueListenableBuilder(
          valueListenable: collectionDataListValueNotifier,
          builder: (context,
              List<CollectionDataListResponseModel> collectionDataList, child) {
            if (collectionDataList.isNotEmpty) {
              return BmwPieChart(
                totalIncineration: totalIncineration,
                totalQuantity: totalQuantity,
                totalAutoclave: totalAutoClave,
                totalRecyclable: totalRecyclables,
              );
            } else {
              return ValueListenableBuilder(
                  valueListenable: processingDataListValueNotifier,
                  builder: (context,
                      List<ProcessingDataListResponseModel> processingDataList,
                      child) {
                    if (processingDataList.isNotEmpty) {
                      return BmwPieChart(
                        totalIncineration: totalIncineration,
                        totalQuantity: totalQuantity,
                        totalAutoclave: totalAutoClave,
                        totalRecyclable: totalRecyclables,
                      );
                    } else {
                      return ValueListenableBuilder(
                          valueListenable: recyclableDataListValueNotifier,
                          builder: (context,
                              List<RecyclableDataListResponseModel>
                                  recyclableDataList,
                              child) {
                            if (recyclableDataList.isNotEmpty) {
                              return BmwPieChart(
                                totalIncineration: totalIncineration,
                                totalQuantity: totalQuantity,
                                totalAutoclave: totalAutoClave,
                                totalRecyclable: totalRecyclables,
                              );
                            } else {
                              return const SizedBox();
                            }
                          });
                    }
                  });
            }
          },
        ),
        const SizedBox(height: 10.0),
        ValueListenableBuilder(
          valueListenable: collectionDataListValueNotifier,
          builder: (context,
              List<CollectionDataListResponseModel> collectionDataList, child) {
            if (collectionDataList.isNotEmpty) {
              return const BmwSummary();
            } else {
              return ValueListenableBuilder(
                  valueListenable: processingDataListValueNotifier,
                  builder: (context,
                      List<ProcessingDataListResponseModel> processingDataList,
                      child) {
                    if (processingDataList.isNotEmpty) {
                      return const BmwSummary();
                    } else {
                      return const SizedBox();
                    }
                  });
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 20.0, right: 20, bottom: 10, top: 10.0),
          child: ValueListenableBuilder(
              valueListenable: recyclableDataListValueNotifier,
              builder: (BuildContext ctx,
                  List<RecyclableDataListResponseModel> recyclableDataList,
                  Widget? child) {
                if (recyclableDataList.isNotEmpty) {
                  recyclableDataList.sort(
                      (b, a) => a.recyclableDate!.compareTo(b.recyclableDate!));
                  recyclableList.clear();
                  for (RecyclableDataListResponseModel data
                      in recyclableDataList) {
                    recyclableList.add(OrdinalData(
                        domain: data.recyclableDate!.split("-")[2],
                        measure: num.parse(data.recyclableQty!),
                        color: kReSustainabilityRed));
                  }
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.39,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset:
                              const Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: CarouselSlider(
                      items: dataList
                          .map(
                            (item) => carouselContent(
                                item["data_type"], recyclableDataList),
                          )
                          .toList(),
                      carouselController: carouselController,
                      options: CarouselOptions(
                        height: MediaQuery.of(context).size.height * 0.39,
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
                  );
                } else {
                  return const SizedBox();
                }
              }),
        ),
        ValueListenableBuilder(
            valueListenable: recyclableDataListValueNotifier,
            builder: (BuildContext ctx,
                List<RecyclableDataListResponseModel> recyclableDataList,
                Widget? child) {
              if (recyclableDataList.isNotEmpty) {
                recyclableDataList.sort(
                    (b, a) => a.recyclableDate!.compareTo(b.recyclableDate!));
                recyclableList.clear();
                for (RecyclableDataListResponseModel data
                    in recyclableDataList) {
                  recyclableList.add(OrdinalData(
                      domain: data.recyclableDate!.split("-")[2],
                      measure: num.parse(data.recyclableQty!),
                      color: kReSustainabilityRed));
                }
                return Column(
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: dataList.asMap().entries.map((entry) {
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
                  ],
                );
              } else {
                return const SizedBox();
              }
            }),
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }

  Widget collectionTab() {
    return ListView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ValueListenableBuilder(
            valueListenable: collectionDataListValueNotifier,
            builder: (BuildContext ctx,
                List<CollectionDataListResponseModel> collectionDataList,
                Widget? child) {
              if (collectionDataList.isNotEmpty) {
                collectionList.clear();
                collectionDataList.sort(
                    (b, a) => a.collectionDate!.compareTo(b.collectionDate!));
                for (CollectionDataListResponseModel data
                    in collectionDataList) {
                  if (collectionList.length < 5) {
                    collectionList.add(OrdinalData(
                        domain: data.collectionDate!.split("-")[2],
                        measure: num.parse(data.collectionQty!.toString()),
                        color: kReSustainabilityRed));
                  }
                }
                return Column(
                  children: [
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
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                      barLabelValue:
                                          (group, ordinalData, index) {
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
                    Padding(
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
                    collectionSummaryCard(collectionDataList[0]),
                    const SizedBox(
                      height: 350.0,
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
                      formatNumber(double.tryParse(collectionDataListResponseModel.collectionQty!)!),
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

  Widget collectionSummaryCard(
      CollectionDataListResponseModel collectionDataListResponseModel) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
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
                "Collection Summary",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 117.0,
                    height: 64.0,
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
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400)),
                        const SizedBox(height: 15.0),
                        Text(
                            "${formatNumber(double.tryParse(collectionDataListResponseModel.qtySum.toString())!)} MT",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: kBlueTitleColor,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15.0),
            ],
          )),
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
            valueListenable: processingDataListValueNotifier,
            builder: (BuildContext ctx,
                List<ProcessingDataListResponseModel> processingDataList,
                Widget? child) {
              if (processingDataList.isNotEmpty) {
                processingDataList.sort(
                    (b, a) => a.processingDate!.compareTo(b.processingDate!));
                incinerationList.clear();
                autoclaveList.clear();
                for (ProcessingDataListResponseModel data
                    in processingDataList) {
                  if (incinerationList.length < 5 && autoclaveList.length < 5) {
                    incinerationList.add(OrdinalData(
                        domain: data.processingDate!.split("-")[2],
                        measure:
                            num.parse(data.totalIncinerationQty!.toString()),
                        color: kReSustainabilityRed));
                    autoclaveList.add(OrdinalData(
                        domain: data.processingDate!.split("-")[2],
                        measure: num.parse(data.totalAutoClaveQty!),
                        color: kReSustainabilityRed));
                  }
                }
                return Column(
                  children: [
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

                          height: MediaQuery.of(context).size.height * 0.37,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 35.0,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Text("Processing Trend",
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: kColorBlack)),
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
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  ClipOval(
                                                      child: Container(
                                                          height: 15,
                                                          width: 15,
                                                          color:
                                                              kChartBarColor)),
                                                  const SizedBox(width: 5.0),
                                                  const Text("Incineration",
                                                      style: TextStyle(
                                                          fontSize: 12.0,
                                                          color: kColorBlack))
                                                ],
                                              ),
                                              const SizedBox(height: 3.0),
                                              Row(
                                                children: [
                                                  ClipOval(
                                                      child: Container(
                                                    height: 15,
                                                    width: 15,
                                                    color:
                                                        kAutoclaveGraphColor,
                                                  )),
                                                  const SizedBox(width: 5.0),
                                                  const Text("Autoclave",
                                                      style: TextStyle(
                                                          fontSize: 12.0,
                                                          color: kColorBlack))
                                                ],
                                              )
                                            ]),
                                      ]),
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
                                        stackedBarPaddingPx: 3,
                                        strokeWidthPx: 0,
                                      ),
                                      groupList: [
                                        OrdinalGroup(
                                          id: '1',
                                          chartType: ChartType.bar,
                                          color: kChartBarColor,
                                          data: incinerationList,
                                        ),
                                        OrdinalGroup(
                                          id: '2',
                                          chartType: ChartType.bar,
                                          color: kAutoclaveGraphColor,
                                          data: autoclaveList,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Text("Date",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12.0, color: kColorBlack))
                              ],
                            ),
                          )),
                    ),
                    const SizedBox(height: 5.0),
                    Padding(
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
                                      child: Text("Incineration \n(MT)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: kGreyTitleColor))),
                                  Expanded(
                                      child: Text("Autoclave \n(MT)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: kGreyTitleColor))),
                                  Expanded(
                                      child: Text("Total Weight \n(MT)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: kGreyTitleColor))),
                                ]),
                              ),
                              ListView.builder(
                                  shrinkWrap: true, // <- added
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: processingDataList.take(10).length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return processingCard(
                                        processingDataList[index]);
                                  }),
                            ],
                          )),
                    ),
                    processingSummaryCard(processingDataList[0]),
                    const SizedBox(
                      height: 350.0,
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

  Widget processingCard(
      ProcessingDataListResponseModel processingDataListResponseModel) {
    return Container(
      width: double.infinity,
      color: kWhite,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0, left: 10),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(
                      processingDataListResponseModel.processingDate!)),
                  textAlign: TextAlign.center,
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
                      formatNumber(double.tryParse(processingDataListResponseModel.totalIncinerationQty!)!),
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
                      formatNumber(double.tryParse(processingDataListResponseModel.totalAutoClaveQty!)!),
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
                      formatNumber(double.tryParse(processingDataListResponseModel.totalWeightQty!)!),
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

  Widget processingSummaryCard(
      ProcessingDataListResponseModel processingDataListResponseModel) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0, top: 10.0),
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
                "Processing Summary",
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
                        height: 64.0,
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
                            const Text("Total \nWaste",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kGreenTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(double.tryParse(processingDataListResponseModel.totalWasteSum!.toString())!)} MT",
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
                        height: 64.0,
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
                            const Text("Total \nIncineration",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kGreenTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(double.tryParse(processingDataListResponseModel.totalIncinerationSum!.toString())!)} MT",
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
                        height: 64.0,
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
                            const Text("Total \nAutoclave",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kGreenTitleColor,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 10.0),
                            Text(
                                "${formatNumber(double.tryParse(processingDataListResponseModel.totalAutoclaveSum!.toString())!)} MT",
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
              )
            ],
          )),
    );
  }

  Widget recyclableTab() {
    return ListView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ValueListenableBuilder(
            valueListenable: recyclableDataListValueNotifier,
            builder: (BuildContext ctx,
                List<RecyclableDataListResponseModel> recyclableDataList,
                Widget? child) {
              if (recyclableDataList.isNotEmpty) {
                recyclableDataList.sort(
                    (b, a) => a.recyclableDate!.compareTo(b.recyclableDate!));
                recyclableList.clear();
                for (RecyclableDataListResponseModel data
                    in recyclableDataList) {
                  if (recyclableList.length < 5) {
                    recyclableList.add(OrdinalData(
                        domain: data.recyclableDate!.split("-")[2],
                        measure: num.parse(data.recyclableQty!),
                        color: kReSustainabilityRed));
                  }
                }
                return Column(
                  children: [
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
                          height: MediaQuery.of(context).size.height * 0.37,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 26.0,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Text("Recyclables Trend",
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: kColorBlack)),
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
                                            ClipOval(
                                                child: Container(
                                              height: 15,
                                              width: 15,
                                              color: kChartBarColor,
                                            )),
                                            const SizedBox(width: 5.0),
                                            const Text("Recyclables",
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: kColorBlack))
                                          ],
                                        )
                                      ]),
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
                                          data: recyclableList,
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
                    const SizedBox(
                      height: 5.0,
                    ),
                    Padding(
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
                                      child: Text("Recyclables\n (MT)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: kGreyTitleColor))),
                                  Expanded(
                                      flex: 2,
                                      child: Text("Glass\n (MT)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: kGreyTitleColor))),
                                  Expanded(
                                      flex: 2,
                                      child: Text("Plastic\n (MT)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: kGreyTitleColor))),
                                  Expanded(
                                      flex: 2,
                                      child: Text("Bags\n (MT)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: kGreyTitleColor))),
                                  Expanded(
                                      flex: 2,
                                      child: Text("Card Board\n (MT)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: kGreyTitleColor)))
                                ]),
                              ),
                              ListView.builder(
                                  shrinkWrap: true, // <- added
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: recyclableDataList.take(10).length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return recyclableCard(
                                        recyclableDataList[index]);
                                  }),
                            ],
                          )),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height / 3.7,
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
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 10.0, left: 10.0, right: 10.0),
                              child: recyclableSummaryCard(
                                  recyclableDataList[0]))),
                    ),
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
                          items: dataList
                              .map(
                                (item) => carouselContent(
                                    item["data_type"], recyclableDataList),
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
                      children: dataList.asMap().entries.map((entry) {
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
                      height: 350.0,
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

  Widget recyclableCard(
      RecyclableDataListResponseModel recyclableDataListResponseModel) {
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
                          recyclableDataListResponseModel.recyclableDate!)),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kColorBlack,
                          fontSize: 8.5.sp,
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
                        formatNumber(double.tryParse(recyclableDataListResponseModel.recyclableQty!)!),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: kColorBlack,
                            fontSize: 8.5.sp,
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
                        formatNumber(double.tryParse(recyclableDataListResponseModel.glassQty!)!),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: kColorBlack,
                            fontSize: 8.5.sp,
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
                        formatNumber(double.tryParse(recyclableDataListResponseModel.plasticQty!)!),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: kColorBlack,
                            fontSize: 8.5.sp,
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
                        formatNumber(double.tryParse(recyclableDataListResponseModel.bagsQty!)!),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: kColorBlack,
                            fontSize: 8.5.sp,
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
                        formatNumber(double.tryParse(recyclableDataListResponseModel.cardBoardQty!)!),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: kColorBlack,
                            fontSize: 8.5.sp,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400),
                      ),
                    ))
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

  Widget recyclableSummaryCard(
      RecyclableDataListResponseModel recyclableDataListResponseModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 10.0),
        const Text(
          "Recyclable Summary",
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
                  height: 64.0,
                  decoration: BoxDecoration(
                      color: kRecyclableSummaryColor1,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.6),
                          spreadRadius: 0.5,
                          blurRadius: 2,
                          offset:
                              const Offset(0, 4), // changes position of shadow
                        ),
                      ],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Total\n Material",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: kRecyclableTitleColor,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 10.0),
                      Text(
                          "${formatNumber(double.tryParse(recyclableDataListResponseModel.totalMaterialSum!.toString())!)} MT",
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
                  height: 64.0,
                  decoration: BoxDecoration(
                      color: kRecyclableSummaryColor1,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.6),
                          spreadRadius: 0.5,
                          blurRadius: 2,
                          offset:
                              const Offset(0, 4), // changes position of shadow
                        ),
                      ],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Total\nRecyclable",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: kRecyclableTitleColor,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 10.0),
                      Text(
                          "${formatNumber(double.tryParse(recyclableDataListResponseModel.totalRecyclableSum.toString())!)} MT",
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
                  height: 64.0,
                  decoration: BoxDecoration(
                      color: kRecyclableSummaryColor1,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.6),
                          spreadRadius: 0.5,
                          blurRadius: 2,
                          offset:
                              const Offset(0, 4), // changes position of shadow
                        ),
                      ],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Total\n Bags",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: kRecyclableTitleColor,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 10.0),
                      Text(
                          "${formatNumber(double.tryParse(recyclableDataListResponseModel.totalBagsSum.toString())!)} MT",
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
                  height: 64.0,
                  decoration: BoxDecoration(
                      color: kRecyclableSummaryColor1,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.6),
                          spreadRadius: 0.5,
                          blurRadius: 2,
                          offset:
                              const Offset(0, 4), // changes position of shadow
                        ),
                      ],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Total\n Glass",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: kRecyclableTitleColor,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 10.0),
                      Text(
                          "${formatNumber(double.tryParse(recyclableDataListResponseModel.totalGlassSum.toString())!)} MT",
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
                  height: 64.0,
                  decoration: BoxDecoration(
                      color: kRecyclableSummaryColor1,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.6),
                          spreadRadius: 0.5,
                          blurRadius: 2,
                          offset:
                              const Offset(0, 4), // changes position of shadow
                        ),
                      ],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Total\n CardBoard",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: kRecyclableTitleColor,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 10.0),
                      Text(
                          "${formatNumber(double.tryParse(recyclableDataListResponseModel.totalCardBoardSum.toString())!)} MT",
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
                  height: 64.0,
                  decoration: BoxDecoration(
                      color: kRecyclableSummaryColor1,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.6),
                          spreadRadius: 0.5,
                          blurRadius: 2,
                          offset:
                              const Offset(0, 4), // changes position of shadow
                        ),
                      ],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Total\n Plastic",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: kRecyclableTitleColor,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 10.0),
                      Text(
                          "${formatNumber(double.tryParse(recyclableDataListResponseModel.totalPlasticSum.toString())!)} MT",
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
      ],
    );
  }

  Widget carouselContent(
      String dataType, List<RecyclableDataListResponseModel> dataList) {
    if (dataType == "Bag") {
      if (dataList.isNotEmpty) {
        bagList.clear();
        for (RecyclableDataListResponseModel data in dataList) {
          if (bagList.length < 5) {
            bagList.add(OrdinalData(
                domain: data.recyclableDate!.split("-")[2],
                measure: num.parse(data.bagsQty!),
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text("Recyclables Trend",
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
                              const Text("Bags",
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
                          data: bagList,
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
    } else if (dataType == "Glass") {
      if (dataList.isNotEmpty) {
        glassList.clear();
        for (RecyclableDataListResponseModel data in dataList) {
          if (glassList.length < 5) {
            glassList.add(OrdinalData(
                domain: data.recyclableDate!.split("-")[2],
                measure: num.parse(data.glassQty!),
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                    const Text("Glass",
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
                                data: glassList,
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
    } else if (dataType == "CardBoard") {
      if (dataList.isNotEmpty) {
        cardBoardList.clear();
        for (RecyclableDataListResponseModel data in dataList) {
          if (cardBoardList.length < 5) {
            cardBoardList.add(OrdinalData(
                domain: data.recyclableDate!.split("-")[2],
                measure: num.parse(data.cardBoardQty!),
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text("Recyclables Trend",
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
                              const Text("Cardboard",
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
                          data: cardBoardList,
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
        plasticList.clear();
        for (RecyclableDataListResponseModel data in dataList) {
          if (plasticList.length < 5) {
            plasticList.add(OrdinalData(
                domain: data.recyclableDate!.split("-")[2],
                measure: num.parse(data.plasticQty!),
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text("Recyclables Trend",
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
                              const Text("Plastics",
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
                          data: plasticList,
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
}
