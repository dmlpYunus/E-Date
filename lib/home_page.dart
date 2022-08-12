import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterfirebasedeneme/Utils/instructor.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/login_screen.dart';
import 'package:flutterfirebasedeneme/reservation_screen.dart';
import 'package:flutterfirebasedeneme/signup_screen.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  final textController = TextEditingController();
  AuthService _authService = AuthService();
  CollectionReference instructorsdb =
  FirebaseFirestore.instance.collection("instructors");
  String selectedInst = "1234";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: instructorsdb.orderBy("name").snapshots(),
                      //groceries.snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: Text("Loading..."),
                          );
                        }
                        return ListView(
                          children: snapshot.data!.docs.map((instructors) {
                            return Center(
                              child: ListTile(
                                onTap: (){
                                    selectedInst = instructors['name'];
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> ReservationPage(title: selectedInst)));
                                },
                                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                                trailing: Icon(Icons.access_alarm_rounded),
                                leading: Icon(Icons.insert_invitation_rounded),
                                subtitle: Text(instructors['email']),
                                title: Text(instructors['name']),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                ),
                Text("Selected instructor : $selectedInst"),
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
                            _authService.logOut();
                          },
                          child: Text("Log-Out"),
                        ))
                  ],
                ),
              ],
            )
    );
  }
}
