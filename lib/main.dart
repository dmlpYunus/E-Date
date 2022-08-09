import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/home_page.dart';
import 'package:flutterfirebasedeneme/login_screen.dart';
import 'package:flutterfirebasedeneme/signup_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  Widget build(BuildContext context) {
    CollectionReference groceries =
        FirebaseFirestore.instance.collection("grecories");

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
              return HomePage();
          }else{
            return LoginPage();
          }
          return Column(
            children: [
              Expanded(
                child: StreamBuilder(
                    stream: groceries.orderBy("name").snapshots(),
                    //groceries.snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: Text("Loading..."),
                        );
                      }
                      return ListView(
                        children: snapshot.data!.docs.map((grocery) {
                          return Center(
                            child: ListTile(
                              title: Text(grocery['name']),
                              onLongPress: () {
                                grocery.reference.delete();
                              },
                            ),
                          );
                        }).toList(),
                      );
                    }),
              ),
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 2,
                    child: RaisedButton(
                      color: Colors.blueAccent,
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                      child: Text("Login"),
                    ),
                  ),
                  Flexible(
                      fit: FlexFit.tight,
                      flex: 2,
                      child: RaisedButton(
                        color: Colors.redAccent,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SignupPage()));
                    },
                    child: Text("Sign-Up"),
                  )),Flexible(
                      fit: FlexFit.tight,
                      flex: 4,
                      child: RaisedButton(
                        color: Colors.orangeAccent,
                        onPressed: () {
                          authService.logOut();
                        },
                        child: Text("Log-Out"),
                      ))
                ],
              ),
            ],
          );
        }
      ),
    );
  }
}
