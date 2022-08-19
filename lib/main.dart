import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/fcm/fcm_background_handler.dart';
import 'package:flutterfirebasedeneme/home_page.dart';
import 'package:flutterfirebasedeneme/login_screen.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
AndroidNotificationChannel? channel;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options
        : DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  channel = const AndroidNotificationChannel("e.date", "E-Date",importance: Importance.max);
  await flutterLocalNotificationsPlugin!
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel!);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.instance.getToken().then((value) {
    print('Token $value');
    var a = {'fcmToken' : value};
    FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).update(a);
  });
  runApp(MaterialApp(home: MyApp()));
}



class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final textController = TextEditingController();
  AuthService authService = AuthService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseMessaging.instance.getToken().then((value) {
      print('Token $value');
      var a = {'fcmToken' : value};
      FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).update(a);
    });

    //FirebaseMessaging.instance.subscribeToTopic("demo").then((value) => print('Success'));
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      RemoteNotification? notification = remoteMessage.notification;
      AndroidNotification? android = remoteMessage.notification?.android;
      if(notification != null && android!=null){
        flutterLocalNotificationsPlugin!.show(notification.hashCode,
            notification.title, notification.body, NotificationDetails(
                android: AndroidNotificationDetails(
                    channel!.id,
                    channel!.name,
                    icon: 'launcher_background',
                channelDescription: channel!.description,
                )));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              return HomePage();

            }else{
              return LoginPage();
            }
          }
      ),
    );
  }
}
