import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/login_validator.dart';

class InstructorRegister extends StatefulWidget {
  const InstructorRegister({Key? key}) : super(key: key);

  @override
  State<InstructorRegister> createState() => _InstructorRegisterState();
}

class _InstructorRegisterState extends State<InstructorRegister>
    with AccountValidationMixin {
  AuthService authService = AuthService();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  double width = 0;
  double height = 0;
  var key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBody: false,
        body: Stack(
          children: [buildPageTopView(),buildPageSplash(),buildRegisterForm()],
    ));
  }

  buildPageTopView() {
    return Container(
      width: width,
      height: height * 0.2,
      child: Row(
        children: [
          const SizedBox(width: 25),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
              child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 30,
          ))
        ],
      ),
    );
  }

  buildPageSplash(){
    return Container(
      width: width,
      height: height * 0.15,
      margin: EdgeInsets.only(top: height*0.15),
      child: Image.asset('images/register.png',scale: 1),
    );
  }

  Widget buildRegisterForm() {
    return Container(
      width: width,
      height: height*0.6,
      margin: EdgeInsets.only(top: height * 0.35),
      child: Form(
        key: key,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Enter Credentials To Register Instructors",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey),
              ),
               SizedBox(height: height * 0.02),
              buildNameText(),
              SizedBox(height: height * 0.02),
              buildSurnameText(),
              SizedBox(height: height * 0.02),
              buildEmailText(),
              SizedBox(height: height * 0.02),
              buildPasswordText(),
              SizedBox(height: height * 0.02),
              buildSignUpButton(),
              //const SizedBox(height: 20),
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
            await authService.RegisterInstructor(
                    emailController.text.trim(),
                    passController.text.trim(),
                    nameController.text.trim(),
                    surnameController.text.trim())
                .then((value) =>
                    {displaySnackBar('Instructor Register Successful')});
          } on FirebaseAuthException catch (error) {
            displaySnackBar(error.message!);
          }
        }
      },
    style: ButtonStyle(side: MaterialStateBorderSide.resolveWith((states) => const BorderSide(color: Colors.black,style: BorderStyle.solid)),
    backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
    shadowColor: MaterialStateColor.resolveWith((states) => Colors.transparent)),
      child: const Text("Submit",style: TextStyle(color: Colors.black)),
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
      decoration:
          const InputDecoration(labelText: ("Password"), hintText: "******"),
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
        style: const TextStyle(fontSize: 14),
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
