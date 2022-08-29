import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterfirebasedeneme/admin_screen.dart';
import 'Model/instructor.dart';
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
  Instructor selected = Instructor();
  late bool isAdmin;

  @override
  void initState() {


  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      body:Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: instructorsdb.orderBy("name").snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text("Loading..."),
                          );
                        }
                        return ListView(
                          children: snapshot.data!.docs.map((instructors) {
                            return Center(
                              child: ListTile(
                                onTap: (){
                                  selected = buildInstructor(instructors);
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> ReservationPage(
                                        title: selectedInst,instructor: selected)));
                                },
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                                trailing: const Icon(Icons.access_alarm_rounded),
                                leading: const Icon(Icons.insert_invitation_rounded),
                                subtitle: Text(instructors['email']),
                                title: Text('${instructors['name']} ${instructors['surname']}'),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                ),
                ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const adminScreen()));
                },
                    child: const Text("Admin Screen")),
                Text("Selected instructor : $selectedInst"),
                Row(
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 2,
                      child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueAccent)),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const LoginPage()));
                        },
                        child: const Text("Login"),
                      ),
                    ),
                    Flexible(
                        fit: FlexFit.tight,
                        flex: 2,
                        child: RaisedButton(
                          color: Colors.redAccent,
                          onPressed: () {

                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => const SignupPage()));
                          },
                          child: const Text("Sign-Up"),
                        )),Flexible(
                        fit: FlexFit.tight,
                        flex: 4,
                        child: RaisedButton(
                          color: Colors.orangeAccent,
                          onPressed: () {
                            _authService.logOut();
                          },
                          child: const Text("Log-Out"),
                        ))
                  ],
                ),
              ],
            )
    );
  }

  Instructor buildInstructor(QueryDocumentSnapshot inst){
    if(inst['fcmToken'] == null){
      return Instructor.withValues(inst['id'], inst['name'], inst['email'], inst['surname'], "Computer");
    }else{
      return Instructor.withFcm(inst['id'],
          inst['name'],
          inst['email'],
          inst['surname'],"Computer",inst['fcmToken']);
    }
  }
  issAdmin(){
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
  }
}
