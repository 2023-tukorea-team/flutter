import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:team2/provider/UserProvider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:team2/theme/Colors.dart';

import 'config/NaverMapConfig.dart';
import 'config/firebase_options.dart';
import 'page/LoginPage.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("백그라운드 메시지 처리.. ${message.notification!.body!}");
}

void initializeNotification() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  ?.createNotificationChannel(const AndroidNotificationChannel('high_importance_channel', 'high_importance_notification', importance: Importance.max));

  await flutterLocalNotificationPlugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings("@mipmap/ic_launcher"),
  ));

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  initializeNotification();
  await NaverMapSdk.instance.initialize(clientId: NaverMapConfig.ClientID);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()), // UserProvider 추가
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: blueStyle6,
        appBarTheme: AppBarTheme(
          backgroundColor: blueStyle5,
          centerTitle: true,
          toolbarHeight: 80,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 32,
            color: whiteStyle2,
          ),
          iconTheme: IconThemeData(color: whiteStyle2),
        ),
        fontFamily: "Pretendard",
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var messageString = "";

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        FlutterLocalNotificationsPlugin().show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails('high_importance_channel', 'high_importance_nofitication', importance: Importance.max,
            ),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("메시지 내용: $messageString"),
          ],
        )
      )
    );
  }
}