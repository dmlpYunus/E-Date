
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> firebaseBackgroundHandler(RemoteMessage remoteMessage) async {
  await Firebase.initializeApp();
  print('Handle Here');
}