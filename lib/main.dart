import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterfirebasedeneme/admin_screen.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/fcm/fcm_background_handler.dart';
import 'package:flutterfirebasedeneme/instructor_homepage.dart';
import 'package:flutterfirebasedeneme/student_home_page.dart';
import 'package:flutterfirebasedeneme/login_screen.dart';
import 'firebase_options.dart';


FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
AndroidNotificationChannel? channel;
Map<String, dynamic>? currentUser;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  channel = const AndroidNotificationChannel("e.date", "E-Date",
      importance: Importance.max);
  await flutterLocalNotificationsPlugin!
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel!);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  if(FirebaseAuth.instance.currentUser != null) {
    await FirebaseMessaging.instance.getToken().then((value) {
      var a = {'fcmToken': value};
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update(a);
    });
  }

  runApp(const MaterialApp(home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final textController = TextEditingController();
  AuthService authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    if(_firebaseAuth.currentUser != null){
      FirebaseMessaging.instance.getToken().then((value) {
        print('Token $value');
        var a = {'fcmToken': value};
        _firestore
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser?.uid.toString())
            .update(a);
        printUserRole();
      });
    }
    //FirebaseMessaging.instance.subscribeToTopic("demo").then((value) => print('Success'));
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      RemoteNotification? notification = remoteMessage.notification;
      AndroidNotification? android = remoteMessage.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin!.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(
              channel!.id,
              channel!.name,
              icon: 'launcher_background',
              channelDescription: channel!.description,
            )));
      }
    });
  }

  printUserRole() async {
    print(await authService.getCurrentUserRole());
  }

  Future<bool> isStudent() async {
    return await authService.getCurrentUserRole() == 'student';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body :StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return  FutureBuilder(
                  future: authService.getCurrentUserRole(),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Center(child: CircularProgressIndicator());
                    }else if(snapshot.connectionState == ConnectionState.none){
                      return const Center(
                        child: Text('Internet Connection Required'),
                      );
                    }else{
                      if (snapshot.hasData) {
                        if (snapshot.data == 'student') {
                          return  HomePage();
                        } else if(snapshot.data == 'instructor'){
                          return  InstructorHomepage();
                        }else{
                          return adminScreen();
                        }
                      } else {
                        return  LoginPage();
                      }
                    }
                  },
                );
              } else {
                return  LoginPage();
              }
            })
    );

        /*FutureBuilder(
        future: isStudent(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if(snapshot.hasData){
            if(snapshot.data!){
              return HomePage();
            }else{
              return InstructorHomepage();
            }
          }else{
            return LoginPage();
          }
        },
      )*/

        /*StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              if(authService.getCurrentUserRole() == 'student'){
                return HomePage();
              }
              else{
                return InstructorHomepage();
              }
              return HomePage();
            }else{
              return LoginPage();
            }
          }
      ),*/
  }
}
