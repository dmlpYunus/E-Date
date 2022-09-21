import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebasedeneme/ForgetPasswordScreen.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/login_validator.dart';
import 'package:flutterfirebasedeneme/signup_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with AccountValidationMixin {
  AuthService authService = AuthService();
  final emailEditor = TextEditingController();
  final passEditor = TextEditingController();
  late double height,width;
  late String? errorMessage;


  var key = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
        key: key,
        child: Padding(
          padding: const EdgeInsets.only(left: 20,right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              Text('Welcome To E-Date System',style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              )),
              SizedBox(height: 100),
              Image.asset('images/password.png',scale: 4),
              SizedBox(height: 50),
              TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: emailEditor,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateMail,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(left: 18),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                      labelText: ("E-Mail"), hintText: ("xxxx@isik.edu.tr"),border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20),)
                  )),
                ),
                SizedBox(height: 20),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: passEditor,
                  keyboardType: TextInputType.visiblePassword,
                  validator: validatePassword,
                  decoration:
                      const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 18),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                          labelText: ("Password"), hintText: "*******",border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))
                      )),
                  obscureText: true,
                ),
              Container(
                margin: EdgeInsets.only(top:20),
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: StadiumBorder(side: BorderSide(color: Colors.black))
                  ),
                  onPressed: () async {
                    if (key.currentState!.validate()) {
                      key.currentState!.save();
                      try{
                       await authService
                          .signIn(emailEditor.text, passEditor.text);
                      }on FirebaseAuthException catch(error){
                       displayDialog("Login Failed", error.message!, context);
                      }
                    }
                  },
                  child: Text("Sign-In"),
                ),
              ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  TextButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPasswordPage()));
                   }, child: Text("Forget My Password")),
                  MaterialButton(child: Text("Don't Have An Account ?"),
                    onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage()));
                    },),
                  ],
                )
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
