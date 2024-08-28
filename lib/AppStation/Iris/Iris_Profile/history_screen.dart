import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xcel;

import '../../../Screens/home/home.dart';
import '../../../Utility/shared_preferences_string.dart';
import '../../../Utility/utils/constants.dart';
import '../../../custom_sharedPreference.dart';
import '../api/get_history_date_list_api_service.dart';
import '../model/history_date_list_model.dart';
import 'history_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  final String sbuCode;
  const HistoryScreen({super.key, required this.sbuCode});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late TextEditingController dateInputController = TextEditingController();
  late HistoryDateListRequestModel historyDateListRequestModel;
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 100)),
    end: DateTime.now(),
  );

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  bool isDateSelect = false;

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  String filePath = "";
  String excelName = "";
  String dateFilename = "";
  String sbu = "";

  List<HistoryDateListResponseModel> excelData = [];

  @override
  void initState() {
    sbu = widget.sbuCode;
    getConnectivity();
    super.initState();
  }

  void showLocalNotification(String title, String body) {
    const androidNotificationDetail = AndroidNotificationDetails(
      '0',
      'general',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        "Reone History",
      ),
    );
    const iosNotificatonDetail = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      iOS: iosNotificatonDetail,
      android: androidNotificationDetail,
    );
    const androidInitializationSetting =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInitializationSetting = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
        android: androidInitializationSetting, iOS: iosInitializationSetting);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: (
      id,
    ) async {
      OpenFilex.open(id.payload);
    });
    flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: filePath,
    );
  }

  String generateRandom() {
    Random random = Random();
    String num = '';
    for (int i = 0; i < 6; i++) {
      num = num + random.nextInt(9).toString();
    }
    return num;
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('az');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "History",
          style: TextStyle(
              fontFamily: "ARIAL",
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        leading: InkWell(
            onTap: () {
              Navigator.pop(context, true);
            },
            child: const Icon(Icons.arrow_back_ios)),
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
        ],
      ),
      body: Stack(
        key: const ValueKey('appStationContainer1'),
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        height: 35,
                        width: 60.w,
                        child: TextField(
                          style: const TextStyle(
                              fontFamily: "ARIAL",
                              color: Colors.black,
                              fontSize: 14.0),
                          textAlign: TextAlign.left,
                          readOnly: true,
                          controller: dateInputController,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.only(top: 10, left: 20.0),
                            hintText: "Select Date",
                            hintStyle: const TextStyle(
                                fontFamily: "ARIAL", color: Colors.black),
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
                          },
                        ),
                      ),
                      // ValueListenableBuilder(
                      //   valueListenable: historyDateListValueNotifier,
                      //   builder: (BuildContext ctx,
                      //       List<HistoryDateListResponseModel> historyDateList,
                      //       Widget? child) {
                      //     if (historyDateList.isNotEmpty) {
                      //       return IconButton(
                      //         onPressed: () async {
                      //           await excelSave();
                      //         },
                      //         icon: Icon(
                      //           Icons.file_download_outlined,
                      //           size: 3.h,
                      //         ),
                      //       );
                      //     } else {
                      //       return const SizedBox();
                      //     }
                      //   },
                      // ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20, top: 20),
                  child: Container(
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF7FFFF),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: Color(0xFF8B8080)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x1EB0B0B0),
                          blurRadius: 2,
                          offset: Offset(1, 2),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: historyDateListValueNotifier,
                      builder: (BuildContext ctx,
                          List<HistoryDateListResponseModel> historyDateList,
                          Widget? child) {
                        excelData.clear();
                        if (historyDateList.isNotEmpty) {
                          if (dateInputController.text.isEmpty) {
                            DateTime startDate = DateFormat('MM/dd/yyyy')
                                .parse(historyDateList.first.collectionDate!);
                            DateTime endDate = DateFormat('MM/dd/yyyy')
                                .parse(historyDateList.last.collectionDate!);
                            String formattedDate =
                                "${DateFormat("dd-MM-yyyy").format(startDate)} to ${DateFormat("dd-MM-yyyy").format(endDate)}";
                            excelName =
                                'Reone_${"${generateRandom()}_$formattedDate"}.xlsx';
                            debugPrint(excelName);
                          }
                          excelData.addAll(historyDateList);
                          return SizedBox(
                              height: 600.0,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: historyDateList.take(10).length,
                                itemBuilder: (BuildContext context, int index) {
                                  debugPrint(excelData.length.toString());
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child:
                                        historyDateCard(historyDateList[index]),
                                  );
                                },
                              ));
                        } else {
                          excelData.clear();
                          return const Center(
                            child: Text("No record available"),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      saveText: "Search",
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
      useRootNavigator: false,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    setState(() {
      dateRange = newDateRange ?? dateRange;
      if (newDateRange == null) {
        if (dateRange.start ==
                DateTime.now().subtract(const Duration(days: 100)) &&
            dateRange.end == DateTime.now()) {
          dateInputController.clear();
        }
      } else {
        excelName = "";
        dateInputController.clear();
        isDateSelect = true;
        dateInputController.text =
            "${DateFormat('dd/MM/yyyy').format(dateRange.start)} to ${DateFormat('dd/MM/yyyy').format(dateRange.end)}";
        getConnectivity();
        String startDate = DateFormat('dd-MM-yyyy').format(dateRange.start);
        String endDate = DateFormat('dd-MM-yyyy').format(dateRange.end);
        String formattedDate = "$startDate to $endDate";
        excelName = 'Reone_${"${generateRandom()}_$formattedDate"}.xlsx';
        debugPrint(excelName);
      }
    });
  }

  Widget historyDateCard(
      HistoryDateListResponseModel historyDateListResponseModel) {
    DateTime apiDate = DateFormat("MM/dd/yyyy")
        .parse(historyDateListResponseModel.collectionDate!);
    String formattedDate = DateFormat("dd/MM/yyyy").format(apiDate);

    return Container(
      height: 5.h,
      color: const Color(0xFFF7FFFF),
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Row(
          children: [
            Text(formattedDate),
            const Spacer(),
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return HistoryDetailsScreen(
                            historyDateListResponseModel:
                                historyDateListResponseModel,
                            sbuCode: sbu);
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.remove_red_eye_outlined))
          ],
        ),
      ),
    );
  }

  Future<String> getSiteName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("SITE_NAME").toString();
  }

  Future<bool> checkFileExist() async {
    return await File('/storage/emulated/0/Download/$excelName').exists();
  }

  Future excelSave() async {
    // String siteName = await getSiteName();

    final xcel.Workbook workbook = xcel.Workbook();

    if (excelData.isNotEmpty) {
      for (int i = 0; i < excelData.length; i++) {
        final xcel.Worksheet sheet = workbook.worksheets.add();
        sheet.workbook.worksheets[0].visibility =
            xcel.WorksheetVisibility.hidden;

        var data = excelData;
        DateTime apiDate =
            DateFormat("MM/dd/yyyy").parse(data[i].collectionDate!);

        sheet.name = DateFormat("dd/MM/yyyy").format(apiDate);
        final xcel.Range range1 = sheet.getRangeByName('A1');
        range1.setText("SBU code: ${data[i].sbuCode}");
        range1.cellStyle.bold = true;
        range1.rowHeight = 20.00;
        range1.columnWidth = 22.00;

        final xcel.Range range2 = sheet.getRangeByName('B1');
        range2.setText("Date: ${DateFormat("dd/MM/yyyy").format(apiDate)}");
        range2.cellStyle.bold = true;
        range2.rowHeight = 20.00;
        range2.columnWidth = 20.00;

        sheet.getRangeByName('A3').setText('Site Name');
        sheet.getRangeByName('A4').setText('Quantity');
        sheet.getRangeByName('A5').setText('Total Waste');
        sheet.getRangeByName('A6').setText('Total Incineration');
        sheet.getRangeByName('A7').setText('Total Autoclave');
        sheet.getRangeByName('A8').setText('Total Materials');
        sheet.getRangeByName('A9').setText('Total Recyclables');
        sheet.getRangeByName('A10').setText('Total Glass');
        sheet.getRangeByName('A11').setText('Total Bags');
        sheet.getRangeByName('A12').setText('Total Plastics');
        sheet.getRangeByName('A13').setText('Total Card Board');

        sheet.getRangeByName('B3').cellStyle.hAlign = xcel.HAlignType.right;
        sheet.getRangeByName('B4').cellStyle.hAlign = xcel.HAlignType.right;
        sheet.getRangeByName('B5').cellStyle.hAlign = xcel.HAlignType.right;
        sheet.getRangeByName('B6').cellStyle.hAlign = xcel.HAlignType.right;
        sheet.getRangeByName('B7').cellStyle.hAlign = xcel.HAlignType.right;
        sheet.getRangeByName('B8').cellStyle.hAlign = xcel.HAlignType.right;
        sheet.getRangeByName('B9').cellStyle.hAlign = xcel.HAlignType.right;
        sheet.getRangeByName('B10').cellStyle.hAlign = xcel.HAlignType.right;
        sheet.getRangeByName('B11').cellStyle.hAlign = xcel.HAlignType.right;
        sheet.getRangeByName('B12').cellStyle.hAlign = xcel.HAlignType.right;
        sheet.getRangeByName('B13').cellStyle.hAlign = xcel.HAlignType.right;

        sheet.getRangeByName('B3').setText(data[i].siteName ?? "null");
        sheet.getRangeByName('B4').setText(data[i].quantity == null
            ? "0.0"
            : "${double.tryParse(data[i].quantity!)?.toStringAsFixed(2) ?? 0.0} MT");
        sheet.getRangeByName('B5').setText(data[i].totalWaste == null
            ? "0.0"
            : "${double.tryParse(data[i].totalWaste!)?.toStringAsFixed(2) ?? 0.0} MT");
        sheet.getRangeByName('B6').setText(data[i].totalIncineration == null
            ? "0.0"
            : "${double.tryParse(data[i].totalIncineration!)?.toStringAsFixed(2) ?? 0.0} MT");
        sheet.getRangeByName('B7').setText(data[i].totalAutoclave == null
            ? "0.0"
            : "${double.tryParse(data[i].totalAutoclave!)?.toStringAsFixed(2) ?? 0.0} MT");
        sheet.getRangeByName('B8').setText(data[i].totalMaterial == null
            ? "0.0"
            : "${double.tryParse(data[i].totalMaterial!)?.toStringAsFixed(2) ?? 0.0} MT");
        sheet.getRangeByName('B9').setText(data[i].totalRecyclable == null
            ? "0.0"
            : "${double.tryParse(data[i].totalRecyclable!)?.toStringAsFixed(2) ?? 0.0} MT");
        sheet.getRangeByName('B10').setText(data[i].totalGlass == null
            ? "0.0"
            : "${double.tryParse(data[i].totalGlass!)?.toStringAsFixed(2) ?? 0.0} MT");
        sheet.getRangeByName('B11').setText(data[i].totalBags == null
            ? "0.0"
            : "${double.tryParse(data[i].totalBags!)?.toStringAsFixed(2) ?? 0.0} MT");
        sheet.getRangeByName('B12').setText(data[i].totalPlastic == null
            ? "0.0"
            : "${double.tryParse(data[i].totalPlastic!)?.toStringAsFixed(2) ?? 0.0} MT");
        sheet.getRangeByName('B13').setText(data[i].totalCardboard == null
            ? "0.0"
            : "${double.tryParse(data[i].totalCardboard!)?.toStringAsFixed(2) ?? 0.0} MT");

        final xcel.ExcelSheetProtectionOption options =
            xcel.ExcelSheetProtectionOption();
        options.all = true;
        // Protecting the Worksheet by using a Password
        sheet.protect('Password');
      }

      // Directory? dir;
      if (Platform.isIOS) {
        final Directory directory = await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/$excelName';
        debugPrint(filePath);
        final List<int> bytes = workbook.saveAsStream();
        final File file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);
        showLocalNotification(excelName, "File Downloaded SuccessFully!");
      } else if (Platform.isAndroid) {
        var device = await DeviceInfoPlugin().androidInfo;
        List<String> versionParts = device.version.release.split('.');
        int androidVersion = int.parse(versionParts[0]);
        // double release = double.parse(android.version.release);
        debugPrint(androidVersion.toString());
        if (androidVersion < 10) {
          await Permission.storage.isGranted.then((value) async {
            if (value) {
              await Permission.notification.isDenied.then((value) async {
                if (value) {
                  await Permission.notification.request().then((value) async {
                    if (value.isGranted) {
                      if (await checkFileExist()) {
                        debugPrint("Check file Exist : $checkFileExist");
                        showLocalNotification(
                            excelName, "File Already Existed!");
                      } else {
                        debugPrint("Check file Exist : $checkFileExist");
                        filePath = '/storage/emulated/0/Download/$excelName';
                        debugPrint(filePath);
                        final List<int> bytes = workbook.saveAsStream();
                        await File(filePath).writeAsBytes(bytes);
                        debugPrint("Permission Granted");
                        showLocalNotification(
                            excelName, "File Downloaded SuccessFully!");
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Notification Permission Denied!"),
                      ));
                    }
                  });
                } else {
                  filePath = '/storage/emulated/0/Download/$excelName';
                  debugPrint(filePath);
                  final List<int> bytes = workbook.saveAsStream();
                  File(filePath).writeAsBytes(bytes);
                  debugPrint("Permission Granted");
                  showLocalNotification(
                      excelName, "File Downloaded SuccessFully!");
                }
              });
            } else {
              await Permission.storage.request().then((value) async {
                if (value.isGranted) {
                  await Permission.notification.isDenied.then((value) async {
                    if (value) {
                      await Permission.notification
                          .request()
                          .then((value) async {
                        if (value.isGranted) {
                          Future<bool> checkFileExist =
                              File('/storage/emulated/0/Download/$excelName')
                                  .exists();
                          if (await checkFileExist) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("File Already Exist!"),
                            ));
                          } else {
                            filePath =
                                '/storage/emulated/0/Download/$excelName';
                            debugPrint(filePath);
                            final List<int> bytes = workbook.saveAsStream();
                            await File(filePath).writeAsBytes(bytes);
                            debugPrint("Permission Granted");
                            showLocalNotification(
                                excelName, "File Downloaded SuccessFully!");
                          }
                        }
                      });
                    } else {
                      filePath = '/storage/emulated/0/Download/$excelName';
                      debugPrint(filePath);
                      final List<int> bytes = workbook.saveAsStream();
                      File(filePath).writeAsBytes(bytes);
                      debugPrint("Permission Granted");
                      showLocalNotification(
                          excelName, "File Downloaded SuccessFully!");
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Storage Permission Denied!"),
                  ));
                }
              });
            }
          });
        } else {
          await Permission.notification.isDenied.then((value) async {
            if (value) {
              await Permission.notification.request().then((value) async {
                if (value.isGranted) {
                  if (await checkFileExist()) {
                    debugPrint("Check file Exist : $checkFileExist");
                    showLocalNotification(excelName, "File Already Existed!");
                  } else {
                    debugPrint("Check file Exist : $checkFileExist");
                    filePath = '/storage/emulated/0/Download/$excelName';
                    debugPrint(filePath);
                    final List<int> bytes = workbook.saveAsStream();
                    await File(filePath).writeAsBytes(bytes);
                    debugPrint("Permission Granted");
                    showLocalNotification(
                        excelName, "File Downloaded SuccessFully!");
                  }
                }
              });
            } else {
              if (await checkFileExist()) {
                debugPrint("Check file Exist : $checkFileExist");
                showLocalNotification(excelName, "File Already Existed!");
              } else {
                debugPrint("Check file Exist : $checkFileExist");
                filePath = '/storage/emulated/0/Download/$excelName';
                debugPrint(filePath);
                final List<int> bytes = workbook.saveAsStream();
                await File(filePath).writeAsBytes(bytes);
                debugPrint("Permission Granted");
                showLocalNotification(
                    excelName, "File Downloaded SuccessFully!");
              }
            }
          });
        }
      }
      workbook.dispose();
    }
  }

  getInit() {
    historyDateListRequestModel = HistoryDateListRequestModel();
    historyDateListRequestModel.fromDate = dateInputController.text == ""
        ? ""
        : DateFormat('yyyy-MM-dd').format(dateRange.start);
    historyDateListRequestModel.toDate = dateInputController.text == ""
        ? ""
        : DateFormat('yyyy-MM-dd').format(dateRange.end);
    GetHistoryDateListAPIService getHistoryDateListAPIService =
        GetHistoryDateListAPIService();
    getHistoryDateListAPIService.getHistoryDateListApiCall(
        historyDateListRequestModel, sbu);
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
}
