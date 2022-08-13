import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/login_validator.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);
  @override
  State<SignupPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignupPage> with AccountValidationMixin {
  @override
  AuthService authService = AuthService();
  final emailEditor = TextEditingController();
  final passEditor = TextEditingController();

  var key = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: key,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welcome To E-Date", textAlign: TextAlign.center),
              SizedBox(height: 20),
              buildEmailText(),
              SizedBox(height: 20),
              buildPasswordText(),
              SizedBox(height: 20),
              buildSignUpButton(),
              SizedBox(height: 20),
              buildLoginPageButton(),
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

  Widget buildEmailText() {
    return TextFormField(
      controller: emailEditor,
      keyboardType: TextInputType.emailAddress,
      validator: validateMail,
      decoration: InputDecoration(
          labelText: ("E-Mail"), hintText: ("xxxx@isik.edu.tr")),
    );
  }

  Widget buildPasswordText() {
    return TextFormField(
      controller: passEditor,
      keyboardType: TextInputType.visiblePassword,
      validator: validatePassword,
      decoration: InputDecoration(labelText: ("Password"), hintText: "***"),
      obscureText: true,
    );
  }

  Widget buildSignUpButton() {
    return ElevatedButton(
      onPressed: () async {
        if (key.currentState!.validate()) {
          key.currentState!.save();
          try {
            await authService.signUp(emailEditor.text, passEditor.text);
          } on FirebaseAuthException catch (error) {
            //displayDialog("Sign-Up Failed", error.message!, context);
            displaySnackBar(error.message!);
          }
        }
      },
      child: Text("Sign-Up"),
    );
  }

  void displaySnackBar(String message) {
    var snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize:14),
        textAlign: TextAlign.center,
      ),
      dismissDirection: DismissDirection.down,
      margin: const EdgeInsets.all(10),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.blueAccent,
      duration: const Duration(seconds: 6),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget buildLoginPageButton() {
    return MaterialButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text("Already Have An Account?"));
  }
}
