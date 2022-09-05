import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/login_validator.dart';

class InstructorRegister extends StatefulWidget {
  const InstructorRegister({Key? key}) : super(key: key);

  @override
  State<InstructorRegister> createState() => _InstructorRegisterState();
}

class _InstructorRegisterState extends State<InstructorRegister> with AccountValidationMixin {
  AuthService authService = AuthService();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();

  var key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: key,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Enter Credentials To Register Instructors", textAlign: TextAlign.center,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.blueGrey),),
              const SizedBox(height: 20),
              buildNameText(),
              const SizedBox(height: 20),
              buildSurnameText(),
              const SizedBox(height: 20),
              buildEmailText(),
              const SizedBox(height: 20),
              buildPasswordText(),
              const SizedBox(height: 20),
              buildSignUpButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSignUpButton() {
    return ElevatedButton(
      onPressed: () async {
        if (key.currentState!.validate()) {
          key.currentState!.save();
          try {
            await authService.RegisterInstructor(emailController.text.trim()
                ,passController.text.trim()
                ,nameController.text.trim()
                ,surnameController.text.trim()
            ).then((value) =>
            {
              displaySnackBar('Instructor Register Successfull')
            });
          } on FirebaseAuthException catch (error) {
            displaySnackBar(error.message!);
          }
        }
      },
      child: const Text("Sign-Up"),
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
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      validator: validateMail,
      decoration: const InputDecoration(
          labelText: ("E-Mail"), hintText: ("xxxx@isikun.edu.tr")),
    );
  }

  Widget buildPasswordText() {
    return TextFormField(
      controller: passController,
      keyboardType: TextInputType.visiblePassword,
      validator: validatePassword,
      decoration: const InputDecoration(labelText: ("Password"), hintText: "***"),
      obscureText: true,
    );
  }

  Widget buildNameText() {
    return TextFormField(
      controller: nameController,
      keyboardType: TextInputType.name,
      validator: validateName,
      decoration: const InputDecoration(labelText: ("Name")),
      obscureText: false,
    );
  }

  Widget buildSurnameText() {
    return TextFormField(
      controller: surnameController,
      keyboardType: TextInputType.name,
      validator: validateSurname,
      decoration: const InputDecoration(labelText: ("Surname")),
      obscureText: false,
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


}
