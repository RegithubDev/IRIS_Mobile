import 'dart:async';
import 'dart:convert';
import 'package:cron/cron.dart';
import 'package:flutter/cupertino.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:resus_test/Screens/home/rewards.dart';
import 'package:resus_test/Screens/home/widgets/help_desk.dart';
import 'package:resus_test/Screens/home/widgets/nav_bar_item_widget.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:resus_test/Utility/utils/constants.dart';
import '../../AppStation/NewAppStation.dart';
import '../../Utility/MySharedPreferences.dart';
import '../../Utility/api_Url.dart';
import '../../Utility/shared_preferences_string.dart';
import '../../custom_sharedPreference.dart';
import '../../data/pref_manager.dart';
import '../../database/database.dart';
import '../../database/department/model_department.dart';
import '../../database/project/model_project.dart';
import '../../database/sbu/model_sbu.dart';
import '../../database/themes/model_themes.dart';
import '../../database/user/model_user.dart';
import '../drawer/drawer.dart';
import '../login/login_page.dart';
import '../notification/notification.dart';
import 'home_page.dart';
import 'widgets/widgets.dart';

class Home extends StatefulWidget {
  final GoogleSignInAccount? googleSignInAccount;
  final String userId;
  final String emailId;
  int? initialSelectedIndex = 0;

  Home(
      {super.key,
      required this.googleSignInAccount,
      required this.userId,
      required this.emailId,
      required this.initialSelectedIndex});

  @override
  _HomeState createState() =>
      _HomeState(googleSignInAccount, userId, emailId, initialSelectedIndex!);
}

class _HomeState extends State<Home> {
  GoogleSignInAccount? m_googleSignInAccount;
  String m_UserId;
  String m_emailId;
  int m_selectedIndex;

  _HomeState(this.m_googleSignInAccount, this.m_UserId, this.m_emailId,
      this.m_selectedIndex);

  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  bool loadURL = false;

  bool isDrawerOpen = false;

  PageController? _pageController;
  final websiteUri = Uri.parse(
      "https://play.google.com/store/apps/details?id=com.google.android.apps.dynamite");

  @override
  void initState() {
    getConnectivity();
    _pageController = PageController(
      initialPage: m_selectedIndex,
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _pageController?.dispose();
    _googleSignIn.signInSilently();
    if (m_googleSignInAccount != null) {
      _handleGetContact(m_googleSignInAccount!);
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
                    setState(() {
                      loadURL = true;
                    });
                    var cron = Cron();
                    //Cron will run Every sunday 7.30 am
                    cron.schedule(Schedule.parse('30  7  *  *  0'), () async {
                      MySharedPreferences.instance
                          .getCityStringValue('JSESSIONID')
                          .then((session) async {
                        logoutAPICall(session);
                      });
                    });

                    fetchSbuList();
                    fetchDepartmentList();
                    fetchProjectList();
                    fetchUserList();
                    fetchThemeList();
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
      setState(() {
        isAlertSet = true;
        loadURL = false;
      });
    } else {
      setState(() {
        loadURL = true;
      });
      var cron = Cron();
      //Cron will run Every sunday 7.30 am
      cron.schedule(Schedule.parse('30  7  *  *  0'), () async {
        MySharedPreferences.instance
            .getCityStringValue('JSESSIONID')
            .then((session) async {
          logoutAPICall(session);
        });
      });

      fetchSbuList();
      fetchDepartmentList();
      fetchProjectList();
      fetchUserList();
      fetchThemeList();
    }
  }

  _selectPage(int index) {
    if (_pageController!.hasClients) _pageController!.jumpToPage(index);
    setState(() {
      m_selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pages = [
      loadURL == true
          ? HomePage(
              googleSignInAccount: m_googleSignInAccount,
              userId: m_UserId,
              emailId: m_emailId)
          : const SizedBox(),
      const HelpDesk(),
      Container(),
      Container(),
      // const AppStation(),
      const NewAppStation(),
    ];
    return Stack(
      key: const ValueKey('homeContainer'),
      children: <Widget>[
        DrawerPage(
          key: const Key("btn_drawer_page"),
          onTap: () {
            setState(
              () {
                xOffset = 0;
                yOffset = 0;
                scaleFactor = 1;
                isDrawerOpen = false;
              },
            );
          },
        ),
        AnimatedContainer(
          transform: Matrix4.translationValues(xOffset, yOffset, 0)
            ..scale(scaleFactor)
            ..rotateY(isDrawerOpen ? -0.5 : 0),
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(isDrawerOpen ? 40 : 0.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isDrawerOpen ? 40 : 0.0),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.white,
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: kReSustainabilityRed,
                elevation: 0.0,
                leading: isDrawerOpen
                    ? IconButton(
                        key: const Key("back_button"),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(
                            () {
                              xOffset = 0;
                              yOffset = 0;
                              scaleFactor = 1;
                              isDrawerOpen = false;
                            },
                          );
                        },
                      )
                    : IconButton(
                        key: const Key("hamburger_btn"),
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            xOffset = size.width - size.width / 3;
                            yOffset = size.height * 0.1;
                            scaleFactor = 0.8;
                            isDrawerOpen = true;
                          });
                        },
                      ),
                title: m_selectedIndex == 4
                    ? Text(
                        'App Station',
                        style: TextStyle(color: kWhite),
                      )
                    : const AppBarTitleWidget(),
                actions: <Widget>[
                  m_selectedIndex == 2
                      ? IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.add,
                          ),
                        )
                      : Row(
                          children: [
                            GestureDetector(
                              child: SvgPicture.asset(
                                  'assets/icons/tropy icon.svg',
                                  color: Colors.white,
                                  semanticsLabel: 'Acme Logo'),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const RewardsScreen()));
                              },
                            ),
                            StreamBuilder<Map<String, dynamic>?>(
                              stream: FlutterBackgroundService().on('update'),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return const Notifications();
                                            },
                                          ),
                                        );
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) {
                                        //       return const NewNotificationsScreen();
                                        //     },
                                        //   ),
                                        // );
                                      },
                                      child: Container(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Stack(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 10.0,
                                                ),
                                                child: SvgPicture.asset(
                                                  'assets/icons/bell icon.svg',
                                                  color: Colors.white,
                                                  semanticsLabel: 'Acme Logo',
                                                ),
                                              ),
                                            ],
                                          )));
                                }

                                final data = snapshot.data!;
                                String? notification_count =
                                    data.length.toString();

                                return GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return const Notifications();
                                          },
                                        ),
                                      );
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Stack(
                                          children: <Widget>[
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  right: 1.0, top: 3.5),
                                              child: Icon(
                                                Icons
                                                    .notifications_none_outlined,
                                                size: 25.0,
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: Container(
                                                height: 15.0,
                                                width: 15.0,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: kReSustainabilityRed,
                                                  border: Border.all(
                                                      width: 1.0,
                                                      color: Colors.white),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 1.0,
                                                              bottom: 1.0),
                                                      child: Text(
                                                        notification_count,
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 7.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        )));
                              },
                            )
                          ],
                        ),
                ],
              ),
              body: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    m_selectedIndex = index;
                  });
                },
                children: pages,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                backgroundColor: kReSustainabilityRed,
                child: SvgPicture.asset(
                  'assets/icons/reone.svg',
                  semanticsLabel: 'Acme Logo',
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: Container(
                decoration: const BoxDecoration(
                    color: Color(0xfff2f3f6),
                    // color: Colors.transparent,
                    border: Border(
                        top: BorderSide(color: Colors.white, width: 0.0))),
                child: BottomAppBar(
                  color:
                      Prefs.isDark() ? const Color(0xff121212) : Colors.white,
                  surfaceTintColor: kReSustainabilityRed,
                  shape: const CircularNotchedRectangle(),
                  notchMargin: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      NavBarItemWidget(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Home(
                                googleSignInAccount: null,
                                userId: '',
                                emailId: '',
                                initialSelectedIndex: 0,
                              ),
                            ),
                          );
                        },
                        image: 'new_home',
                        isSelected: m_selectedIndex == 0,
                        label: 'Home',
                      ),
                      NavBarItemWidget(
                        onTap: () async {
                          _selectPage(1);
                        },
                        image: 'new_helpdesk',
                        isSelected: m_selectedIndex == 1,
                        label: 'Help desk',
                      ),
                      NavBarItemWidget(
                        onTap: () {
                          _selectPage(3);
                        },
                        image: '',
                        isSelected: false,
                        label: '',
                      ),
                      NavBarItemWidget(
                        onTap: () async {
                          var openAppResult = await LaunchApp.openApp(
                            androidPackageName:
                                'com.google.android.apps.dynamite',
                            appStoreLink:
                                'https://play.google.com/store/apps/details?id=com.google.android.apps.dynamite',
                          );
                          if (kDebugMode) {
                            print(
                                'openAppResult => $openAppResult ${openAppResult.runtimeType}');
                          }
                        },
                        image: 'new_chat',
                        isSelected: m_selectedIndex == 3,
                        label: 'Chat',
                      ),
                      NavBarItemWidget(
                        onTap: () {
                          _selectPage(4);
                        },
                        image: 'new_appstation',
                        isSelected: m_selectedIndex == 4,
                        label: 'App station',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '180023549420-laibl7g5ebqfe7lmagf0a2aflhih2g97.apps.googleusercontent.com',
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/calendar.readonly \ https://www.googleapis.com/auth/contacts.readonly'
    ],
  );

  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {});
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {});
      if (kDebugMode) {
        print('People API ${response.statusCode} response: ${response.body}');
      }
      return;
    }
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    final String? namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
      } else {}
    });
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
      (dynamic contact) => (contact as Map<Object?, dynamic>)['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final List<dynamic> names = contact['names'] as List<dynamic>;
      final Map<String, dynamic>? name = names.firstWhere(
        (dynamic name) =>
            (name as Map<Object?, dynamic>)['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }

  logoutAPICall(String sessionId) async {
    var headers = {'Content-Type': 'application/json', 'Cookie': sessionId};
    var request = http.Request('GET', Uri.parse(LOGOUT));
    request.body = json.encode({});
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("control comes here 2");
      }
      MySharedPreferences.instance.setStringValue("IRIS_ROLE_NAME", "");

      CustomSharedPref.setPref<bool>(SharedPreferencesString.isLoggedIn, false);
      CustomSharedPref.setPref<String>(SharedPreferencesString.userId, "");
      CustomSharedPref.setPref<String>(SharedPreferencesString.emailId, "");
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const LoginPage()));
    } else {
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }

  fetchSbuList() async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelSBU;

    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    var request = http.Request('GET', Uri.parse(GET_SBU_LIST));
    request.body = json.encode({});
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      for (Map json in json.decode(response.body)) {
        model_sbu mdpn = model_sbu(null, json["sbu_code"], json["sbu_name"]);
        model_sbu? savedDealer = await _isSbuAvailable(json["sbu_code"]);

        if (savedDealer == null) {
          dao.insertSBU(mdpn);
        } else {
          dao.updateSBU(
              model_sbu(savedDealer.id, json["sbu_code"], json["sbu_name"]));
        }
      }
    } else {
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }

  Future<model_sbu?> _isSbuAvailable(String sbuCode) async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelSBU;
    return dao.findSBUById(sbuCode);
  }

  fetchProjectList() async {
    //TODO this should be split it as 3 function one for database one for json output one for saving data to DB
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelProject;

    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    var request = http.Request('GET', Uri.parse(GET_PROJECTS_LIST));
    request.body = json.encode({});
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      for (Map json in json.decode(response.body)) {
        model_project mdpn =
            model_project(null, json["project_code"], json["project_name"]);
        model_project? savedDealer =
            await _isProjectAvailable(json["project_code"]);

        if (savedDealer == null) {
          dao.insertProject(mdpn);
        } else {
          dao.updateProject(model_project(
              savedDealer.id, json["project_code"], json["project_name"]));
        }
      }
    } else {
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }

  Future<model_project?> _isProjectAvailable(String projectCode) async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelProject;
    return dao.findProjectById(projectCode);
  }

  fetchDepartmentList() async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelDepartment;

    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    var request = http.Request('GET', Uri.parse(GET_DEPARTMENT_LIST));
    request.body = json.encode({});
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      for (Map json in json.decode(response.body)) {
        model_department mdpn = model_department(
            null, json["department_code"], json["department_name"]);
        model_department? savedDealer =
            await _isDepartmentAvailable(json["department_code"]);

        if (savedDealer == null) {
          dao.insertDepartment(mdpn);
        } else {
          dao.updateDepartment(model_department(savedDealer.id,
              json["department_code"], json["department_name"]));
        }
      }
    } else {
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }

  Future<model_department?> _isDepartmentAvailable(
      String departmentCode) async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelDepartment;
    return dao.findDepartmentById(departmentCode);
  }

  fetchUserList() async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelUser;

    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    var request = http.Request('GET', Uri.parse(GET_USER_LIST));
    request.body = json.encode({});
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      for (Map json in json.decode(response.body)) {
        model_user mdpn = model_user(null, json["user_id"], json["user_name"]);
        model_user? savedDealer = await _isUserAvailable(json["user_id"]);

        if (savedDealer == null) {
          dao.insertUser(mdpn);
        } else {
          dao.updateUser(
              model_user(savedDealer.id, json["user_id"], json["user_name"]));
        }
      }
    } else {
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }

  Future<model_user?> _isUserAvailable(String userId) async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelUser;
    return dao.findUserById(userId);
  }

  fetchThemeList() async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelThemes;

    var headers = {
      'Content-Type': 'application/json',
      // 'Cookie': 'JSESSIONID=9DEE293D2AD0499EBF228D9200DF20A6'
      'Cookie': 'JSESSIONID=6672B7A17C21D7F4FF3783D51CE334A5'
    };
    var request = http.Request('GET', Uri.parse(GET_THEME_LIST));
    request.body = json.encode({});
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      for (Map json in json.decode(response.body)) {
        model_themes mdpn =
            model_themes(null, json["theme_code"], json["theme_name"]);
        model_themes? savedDealer =
            await _isThemesAvailable(json["theme_code"]);

        if (savedDealer == null) {
          dao.insertTheme(mdpn);
        } else {
          dao.updateTheme(model_themes(
              savedDealer.id, json["theme_code"], json["theme_name"]));
        }
      }
    } else {
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }

  Future<model_themes?> _isThemesAvailable(String themeCode) async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelThemes;
    return dao.findThemeById(themeCode);
  }
}
