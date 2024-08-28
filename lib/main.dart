import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resus_test/Utility/utils/constants.dart';
import 'package:root/root.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'Screens/routes/route_generator.dart';
import 'Screens/routes/routes.dart';
import 'Utility/MyHttpOverrides.dart';
import 'Utility/MySharedPreferences.dart';
import 'Utility/api_Url.dart';
import 'Utility/utils/themebloc/theme_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  HttpOverrides.global = MyHttpOverrides();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://34fd60e014724a48b7d021a9f817bf72@o4505425767628800.ingest.sentry.io/4505425811341312';
      options.tracesSampleRate = 0.01;
    },
    appRunner: () => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: kReSustainabilityRed),
          useMaterial3: true,
        ),
        home: const MyApp(),
      ),
    ),
  );
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    String latestNotification = "";
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    MySharedPreferences.instance.setStringValue("notification_last_sync_time",
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc()));

    String user_id = prefs.getString('user_id') ?? '54321';
    if ((prefs.getString('JSESSIONID') ?? '') != "") {
      final response = await http.post(Uri.parse(GET_NOTIFICATION_LIST),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.cookieHeader: prefs.getString('JSESSIONID') ?? ''
          },
          body: jsonEncode({
            "user": user_id,
            "last_sync_time": prefs.getString("notification_last_sync_time")
          }),
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200 && response.body != "[]") {
        latestNotification = jsonDecode(response.body)[0]["message"];
      } else {
        latestNotification = "Loading...";

        throw Exception('Failed to load post');
      }
    }
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          888,
          'RE Notifications',
          latestNotification,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );
      }
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    checkRoot();
  }

  Future<void> checkRoot() async {
    bool? result = await Root.isRooted();
    if (result == true) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return BlocProvider(
        create: (context) => ThemeBloc(),
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: _buildWithTheme,
        ),
      );
    });
  }

  Widget _buildWithTheme(BuildContext context, ThemeState state) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: kReSustainabilityRed,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: kReSustainabilityRed,
        ),
        datePickerTheme: const DatePickerThemeData(
          headerBackgroundColor: kReSustainabilityRed
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kReSustainabilityRed,
        ),
        useMaterial3: false,
      ),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child!,
        );
      },
      title: 'Re-Sustainability',
      initialRoute: Routes.splash,
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
