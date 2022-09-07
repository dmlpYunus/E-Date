import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebasedeneme/change_password_screen.dart';
import 'auth_service.dart';

class StudentAccountSettings extends StatefulWidget {
  const StudentAccountSettings({Key? key}) : super(key: key);

  @override
  State<StudentAccountSettings> createState() =>
      _StudentAccountSettingsState();
}

class _StudentAccountSettingsState extends State<StudentAccountSettings> {
  AuthService authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  double width = 0.0;
  double height = 0.0;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Stack(
          children: [buildPageBody(), buildPageTopView()],
        ));
  }

  buildPageTopView() {
    return Container(
      width: width,
      height: height * 0.1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 30,
                    ))),
            Padding(
              padding: EdgeInsets.only(left: width * 0.15),
              child: const Text('Account Settings',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  buildPageBody() {
    return Container(
      width: width,
      height: height * 0.9,
      margin: EdgeInsets.only(top: height * 0.1),
      child: FutureBuilder(
        future: _firestore.collection('users').doc(_firebaseAuth.currentUser!.uid).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if(snapshot.hasData){
            return Column(
              children: [
                Container(
                  width: width,
                  height: height * 0.3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('images/student.png',height: height* 0.15,width: width*0.5),
                      Text('${snapshot.data!.get('name')} ${snapshot.data!.get('surname')}',style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 5),
                      Text(capitalizeFirstLetter(snapshot.data!.get('role'))),
                    ],
                  ),
                ),
                Container(
                  width: width,
                  height: height * 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage(),));
                          },
                          child: const Text('Change Password')),
                      ElevatedButton(
                          onPressed: () {
                            authService.logOut();
                            Navigator.pop(context);
                          },
                          child: const Text('LogOut'))
                    ],
                  ),
                ),
              ],
            );
          }else{
            return const Text('Please Wait');
          }
        },
      ),
    );
  }

  buildProfileView(){

  }

  void displaySnackBar(String message) {
    var snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
      ),
      dismissDirection: DismissDirection.down,
      margin: const EdgeInsets.all(10),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green,
      duration: const Duration(milliseconds: 600),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String capitalizeFirstLetter(String s){
    String capitalizedString = s.characters.first.toUpperCase()+ s.substring(1)  ;
    return capitalizedString;
  }
}
