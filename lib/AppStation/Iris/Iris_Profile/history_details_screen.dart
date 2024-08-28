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
import 'package:resus_test/AppStation/Iris/model/data_from_date_model.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xcel;

import '../../../Screens/home/home.dart';
import '../../../Utility/shared_preferences_string.dart';
import '../../../Utility/utils/constants.dart';
import '../../../custom_sharedPreference.dart';
import '../api/get_data_from_date_api_service.dart';
import '../model/history_date_list_model.dart';

class HistoryDetailsScreen extends StatefulWidget {
  final HistoryDateListResponseModel historyDateListResponseModel;
  final String sbuCode;

  const HistoryDetailsScreen(
      {super.key,
      required this.historyDateListResponseModel,
      required this.sbuCode});

  @override
  State<HistoryDetailsScreen> createState() => _HistoryDetailsScreenState();
}

class _HistoryDetailsScreenState extends State<HistoryDetailsScreen> {
  late HistoryDateListResponseModel mHistoryDateListResponseModel;
  late DataFromDateRequestModel dataFromDateRequestModel;
  NumberFormat formatter = NumberFormat.decimalPatternDigits(
    locale: 'en_us',
    decimalDigits: 2,
  );

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  String filePath = "";
  String excelName = "";
  List<DataFromDateResponseModel> historyDetails = [];
  List<MswDataFromDateResponseModel> mswHistoryDetails = [];
  String sbu = "";

  @override
  void initState() {
    sbu = widget.sbuCode;
    mHistoryDateListResponseModel = widget.historyDateListResponseModel;
    super.initState();
    dataFromDateRequestModel = DataFromDateRequestModel();

    dataFromDateRequestModel.mDate =
        "${mHistoryDateListResponseModel.collectionDate!.split("/")[2]}-${mHistoryDateListResponseModel.collectionDate!.split("/")[0]}-${mHistoryDateListResponseModel.collectionDate!.split("/")[1]}";
    getConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    DateTime apiDate = DateFormat("MM/dd/yyyy")
        .parse(mHistoryDateListResponseModel.collectionDate!);
    debugPrint(apiDate.toString());
    String formattedDate = DateFormat("dd/MM/yyyy").format(apiDate);
    debugPrint(formattedDate);
    excelName =
        'Reone_${generateRandom() + DateFormat("dd-MM-yyyy").format(apiDate)}.xlsx';
    initializeDateFormatting('az');

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

    Future<bool> checkFileExist() async {
      return await File('/storage/emulated/0/Download/$excelName').exists();
    }

    Future excelSave() async {
      String siteName = await getSiteName();

      final xcel.Workbook workbook = xcel.Workbook();
      final xcel.Worksheet sheet = workbook.worksheets[0];

      var data = historyDetails;
      sheet.name = DateFormat("dd/MM/yyyy").format(apiDate);
      final xcel.Range range1 = sheet.getRangeByName('A1');
      range1.setText("SBU code: ${data[0].sbuCode}");
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

      sheet.getRangeByName('B3').setText(siteName);
      sheet.getRangeByName('B4').setText(
          "${double.tryParse(data[0].qtyTotalSum!)?.toStringAsFixed(2)} MT");
      sheet.getRangeByName('B5').setText(
          "${double.tryParse(data[0].wasteTotalSum!)?.toStringAsFixed(2)} MT");
      sheet.getRangeByName('B6').setText(
          "${double.tryParse(data[0].incinerationTotalSum!)?.toStringAsFixed(2)} MT");
      sheet.getRangeByName('B7').setText(
          "${double.tryParse(data[0].autoclaveTotalSum!)?.toStringAsFixed(2)} MT");
      sheet.getRangeByName('B8').setText(
          "${double.tryParse(data[0].materialTotalSum!)?.toStringAsFixed(2)} MT");
      sheet.getRangeByName('B9').setText(
          "${double.tryParse(data[0].recyclableTotalSum!)?.toStringAsFixed(2)} MT");
      sheet.getRangeByName('B10').setText(
          "${double.tryParse(data[0].glassTotalSum!)?.toStringAsFixed(2)} MT");
      sheet.getRangeByName('B11').setText(
          "${double.tryParse(data[0].bagsTotalSum!)?.toStringAsFixed(2)} MT");
      sheet.getRangeByName('B12').setText(
          "${double.tryParse(data[0].plasticTotalSum!)?.toStringAsFixed(2)} MT");
      sheet.getRangeByName('B13').setText(
          "${double.tryParse(data[0].cardBoardTotalSum!)?.toStringAsFixed(2)} MT");

      final xcel.ExcelSheetProtectionOption options =
          xcel.ExcelSheetProtectionOption();
      options.all = true;
      // Protecting the Worksheet by using a Password
      sheet.protect('Password');
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "History Details",
          style: TextStyle(
              fontFamily: "ARIAL",
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        leading: InkWell(
            onTap: (){
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home(
                          googleSignInAccount: null,
                          userId: userId,
                          emailId: emailId,
                          initialSelectedIndex: 0)));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          key: const ValueKey('appStationContainer1'),
          children: [
            Stack(
              children: [
                sbu == "BMW"
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 25.0, right: 10.0, top: 10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    formattedDate,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Spacer(),
                                ValueListenableBuilder(
                                    valueListenable: dataFromDateValueNotifier,
                                    builder: (BuildContext ctx,
                                        List<DataFromDateResponseModel>
                                            dataList,
                                        Widget? child) {
                                      if (dataList.isNotEmpty) {
                                        return IconButton(
                                            onPressed: () async {
                                              await excelSave();
                                            },
                                            icon: Icon(
                                              Icons.file_download_outlined,
                                              size: 3.h,
                                            ));
                                      } else {
                                        return const SizedBox();
                                      }
                                    }),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20, top: 10),
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
                                valueListenable: dataFromDateValueNotifier,
                                builder: (BuildContext ctx,
                                    List<DataFromDateResponseModel> dataList,
                                    Widget? child) {
                                  historyDetails.clear();
                                  if (dataList.isNotEmpty) {
                                    historyDetails = dataList;

                                    return Column(
                                      children: [
                                        FutureBuilder<String>(
                                            future: getSiteName(),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              if (snapshot.hasData) {
                                                return _textField(
                                                    "Site Name", snapshot.data);
                                              } else {
                                                return _textField(
                                                    "Site Name", "");
                                              }
                                            }),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Quantity",
                                            "${formatter.format(double.parse(dataList[0].qtyTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total waste",
                                            "${formatter.format(double.parse(dataList[0].wasteTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total Incineration",
                                            "${formatter.format(double.parse(dataList[0].incinerationTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total Autoclave",
                                            "${formatter.format(double.parse(dataList[0].autoclaveTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total Materials",
                                            "${formatter.format(double.parse(dataList[0].materialTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total Recyclables",
                                            "${formatter.format(double.parse(dataList[0].recyclableTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total Glass",
                                            "${formatter.format(double.parse(dataList[0].glassTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total Bags",
                                            "${formatter.format(double.parse(dataList[0].bagsTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total Plastics",
                                            "${formatter.format(double.parse(dataList[0].plasticTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total Card Board",
                                            "${formatter.format(double.parse(dataList[0].cardBoardTotalSum!))} MT"),
                                        const SizedBox(
                                          height: 5.0,
                                        )
                                      ],
                                    );
                                  } else {
                                    return const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(
                                          child: Text(
                                              "No Data From The Server! Please try again")),
                                    );
                                  }
                                },
                              ),
                            ),
                          )
                        ],
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 25.0, right: 10.0, top: 10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    formattedDate,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Spacer(),
                                ValueListenableBuilder(
                                    valueListenable:
                                        mswDataFromDateValueNotifier,
                                    builder: (BuildContext ctx,
                                        List<MswDataFromDateResponseModel>
                                            dataList,
                                        Widget? child) {
                                      if (dataList.isNotEmpty) {
                                        return IconButton(
                                            onPressed: () async {
                                              await excelSave();
                                            },
                                            icon: Icon(
                                              Icons.file_download_outlined,
                                              size: 3.h,
                                            ));
                                      } else {
                                        return const SizedBox();
                                      }
                                    }),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20, top: 10),
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
                                valueListenable: mswDataFromDateValueNotifier,
                                builder: (BuildContext ctx,
                                    List<MswDataFromDateResponseModel> dataList,
                                    Widget? child) {
                                  mswHistoryDetails.clear();
                                  if (dataList.isNotEmpty) {
                                    mswHistoryDetails = dataList;

                                    return Column(
                                      children: [
                                        FutureBuilder<String>(
                                            future: getSiteName(),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              if (snapshot.hasData) {
                                                return _textField(
                                                    "Site Name", snapshot.data);
                                              } else {
                                                return _textField(
                                                    "Site Name", "");
                                              }
                                            }),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Quantity",
                                            "${formatter.format(double.parse(dataList[0].totalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total waste",
                                            "${formatter.format(double.parse(dataList[0].wasteTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total Incineration",
                                            "${formatter.format(double.parse(dataList[0].incinerationTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total Autoclave",
                                            "${formatter.format(double.parse(dataList[0].autoclaveTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total Materials",
                                            "${formatter.format(double.parse(dataList[0].materialTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total Recyclables",
                                            "${formatter.format(double.parse(dataList[0].recyclableTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total Glass",
                                            "${formatter.format(double.parse(dataList[0].glassTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total Bags",
                                            "${formatter.format(double.parse(dataList[0].bagsTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total Plastics",
                                            "${formatter.format(double.parse(dataList[0].plasticTotalSum!))} MT"),
                                        SizedBox(
                                          height: 1.h,
                                          child: const Divider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        _textField("Total Card Board",
                                            "${formatter.format(double.parse(dataList[0].cardBoardTotalSum!))} MT"),
                                        const SizedBox(
                                          height: 5.0,
                                        )
                                      ],
                                    );
                                  } else {
                                    return const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(
                                          child: Text(
                                              "No Data From The Server! Please try again")),
                                    );
                                  }
                                },
                              ),
                            ),
                          )
                        ],
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String generateRandom() {
    Random random = Random();
    String otp = '';
    for (int i = 0; i < 5; i++) {
      otp = otp + random.nextInt(9).toString();
    }
    return otp;
  }

  Widget _textField(label, value) {
    return Container(
      height: 5.h,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10),
        child: Row(
          children: [
            Text(label),
            const Spacer(),
            Text(value),
          ],
        ),
      ),
    );
  }

  getInit() {
    GetDataFromDateAPIService getDataFromDateAPIService =
        GetDataFromDateAPIService();
    getDataFromDateAPIService.getDataFromDateApiCall(
        dataFromDateRequestModel, sbu);
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

  Future<String> getSiteName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("SITE_NAME").toString();
  }
}
