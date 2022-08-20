import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child:Column(
          children: [
            buildRegisterInstructorButton(),
            buildSeeAllAppointmentsButton(),
          ],
        ),
      ),
    );
  }

  buildRegisterInstructorButton(){
    return ElevatedButton(onPressed: (){
      Navigator.push(context, MaterialPageRoute(builder: (context) => InstructorRegister()));
    },
        child: Text("Register Instructor"));
  }

  buildSeeAllAppointmentsButton(){
    return ElevatedButton(onPressed: (){

    },
        child: Text("All Appointments"));
  }
}
