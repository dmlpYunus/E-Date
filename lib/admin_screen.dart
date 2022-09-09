import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebasedeneme/admin_create_appointment.dart';
import 'package:flutterfirebasedeneme/all_appointments.dart';
import 'package:flutterfirebasedeneme/all_instructors.dart';
import 'package:flutterfirebasedeneme/all_students.dart';
import 'package:flutterfirebasedeneme/instructor_register_screen.dart';
import 'package:flutterfirebasedeneme/login_validator.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';

class adminScreen extends StatefulWidget with AccountValidationMixin{
  const adminScreen({Key? key}) : super(key: key);
  @override
  State<adminScreen> createState() => _adminScreenState();
}

class _adminScreenState extends State<adminScreen> {
  AuthService authService = AuthService();
  double height =0;
  double width = 0;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        child:Stack(
          children: [
            buildAdminTopView(),
            buildAdminScreenSplash(),
            buildAdminScreenBody(),
          ],
        ),
      ),
    );
  }

  
  buildAdminScreenSplash(){
    return Container(
      width: width,
      height: height*0.4,
      margin: EdgeInsets.only(top:height*0.1),
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('images/admin.png',height: 200,width: width*0.5)
      ],  
      ),
    );
  }

  buildAdminScreenBody(){
    return Container(
      width: width,
      height: height*0.4,
      margin: EdgeInsets.only(top:height*0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildRegisterInstructorButton(),
          buildSeeAllAppointmentsButton(),
          buildSeeAllInstructorsButton(),
          buildSeeAllStudentsButton(),
          buildCreateAppointmentButton(),
          buildLogOutButton()
        ],
      ),
    );
  }

  buildAdminTopView(){
    return Container(
      width: width,
      height: height * 0.2,
      child: Row(
        //crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
           Text('Admin Homepage',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  buildRegisterInstructorButton(){
    return ElevatedButton(onPressed: (){
      Navigator.push(context, MaterialPageRoute(builder: (context) => const InstructorRegister()));
    },
        style: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
          shadowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
          fixedSize: MaterialStateProperty.resolveWith((states) => Size(width*0.55,10)),
          side: MaterialStateBorderSide.resolveWith((states) => const BorderSide(color: Colors.black)),
        ),

        child: const Text("Register Instructor",style: TextStyle(color: Colors.black),));
  }

  buildSeeAllAppointmentsButton(){
    return ElevatedButton(onPressed: (){
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AllAppointments()));
    },
        style: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
          shadowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
          fixedSize: MaterialStateProperty.resolveWith((states) => Size(width*0.55,10)),
          side: MaterialStateBorderSide.resolveWith((states) => const BorderSide(color: Colors.black)),
        ),

        child: const Text("All Appointments",style: TextStyle(color: Colors.black),));
  }

  buildSeeAllInstructorsButton() {
    return ElevatedButton(onPressed: (){
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AllInstructors()));
    },
        style: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
          shadowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
          fixedSize: MaterialStateProperty.resolveWith((states) => Size(width*0.55,10)),
          side: MaterialStateBorderSide.resolveWith((states) => const BorderSide(color: Colors.black)),
        ),
        child: const Text("All Instructors",style: TextStyle(color: Colors.black),));
  }

  buildSeeAllStudentsButton() {
    return ElevatedButton(onPressed: (){
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AllStudents()));
    },
        style: ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
      shadowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
      fixedSize: MaterialStateProperty.resolveWith((states) => Size(width*0.55,10)),
      side: MaterialStateBorderSide.resolveWith((states) => const BorderSide(color: Colors.black)),
    ),
        child: const Text("All Students",style: TextStyle(color: Colors.black),));
  }

  buildCreateAppointmentButton(){
    return ElevatedButton(onPressed: (){
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminCreateAppointment()));
    },
        style: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
          shadowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
          fixedSize: MaterialStateProperty.resolveWith((states) => Size(width*0.55,10)),
          side: MaterialStateBorderSide.resolveWith((states) => const BorderSide(color: Colors.black)),
        ),
        child: const Text("Create Appointment",style: TextStyle(color: Colors.black),));
  }

  buildLogOutButton(){
    return ElevatedButton(onPressed: (){
      authService.logOut();
    },
        style: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
          shadowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
          fixedSize: MaterialStateProperty.resolveWith((states) => Size(width*0.55,10)),
          side: MaterialStateBorderSide.resolveWith((states) => const BorderSide(color: Colors.black)),
        ),

        child: const Text("Log-Out",style: TextStyle(color: Colors.black),));
  }

  void updateFcmToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      //var a = {'fcmToken': value};
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({'fcmToken' : value});
    });
  }
}
