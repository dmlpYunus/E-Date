import 'package:flutter/material.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/login_validator.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);
  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPage();
}

class _ForgetPasswordPage extends State<ForgetPasswordPage> with StudentValidationMixin {
  @override
  AuthService authService = AuthService();
  final emailEditor = TextEditingController();
  late String _forgetEmail;

  var key = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: key,
        child: Padding(
          padding: EdgeInsets.only(left:30,right: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              TextFormField(
                controller: emailEditor,
                keyboardType: TextInputType.emailAddress,
                validator: validateMail,
                decoration: const InputDecoration(
                    labelText: ("E-Mail"), hintText: ("xxxx@isik.edu.tr")),
                onSaved: (value){
                  _forgetEmail = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style:  ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.redAccent)) ,
                onPressed: () {
                  if (key.currentState!.validate()) {
                    key.currentState!.save();
                    authService.forgetPassword(_forgetEmail);
                    //Navigator.push(context, MaterialPageRoute(builder : (context) => MyApp()));
                  }
                },
                child: Text("Sign-In"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void displayDialog(String Title, String message, BuildContext context) {
    var alert = AlertDialog(
      title: Text(Title),
      content: Text(message),
    );
    showDialog(context: context, builder: (BuildContext context) => alert);
  }
}

