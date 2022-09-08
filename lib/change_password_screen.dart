import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebasedeneme/ForgetPasswordScreen.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/login_validator.dart';
import 'package:flutterfirebasedeneme/signup_screen.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> with AccountValidationMixin {
  AuthService authService = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final currentPassController = TextEditingController();
  final newPassController = TextEditingController();
  late String? errorMessage;
  late String mail;
  double width = 0.0;
  double height = 0.0;

  @override
  void initState() {
    mail = _firebaseAuth.currentUser!.email!;
  }


  var key = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [buildCurrentPasswordForm(),buildPageTopView(),buildLockDesign()],
      )
    );
  }

  buildPageTopView() {
    return Container(
      width: width,
      height: height * 0.1,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
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
              child: const Text('Change Password',
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

  buildCurrentPasswordForm(){
    return Container(
      margin: EdgeInsets.only(top:250),
      child: Form(
        key: key,
        child: Padding(
          padding: const EdgeInsets.only(left: 20,right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: currentPassController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                validator: validatePassword,
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 18),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                    labelText: ("Current Password"),
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                )),
              ),
              SizedBox(height: 20),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: newPassController,
                keyboardType: TextInputType.visiblePassword,
                validator: validatePassword,
                decoration:
                const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 18),
                    labelText: ("New Password"),border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40))
                )),
                obscureText: true,
              ),
              Container(
                margin: EdgeInsets.only(top:40),
                child: ElevatedButton(
                  style:  ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.redAccent)) ,
                  onPressed: () async {
                    if (key.currentState!.validate()) {
                      key.currentState!.save();
                      AuthCredential credential = EmailAuthProvider
                          .credential(email:_firebaseAuth.currentUser!.email!, password: currentPassController.text);
                      try{
                        await _firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
                        displayDialog('Password Changed', 'Password Updated', context);

                      }on FirebaseAuthException catch(error){
                        displayDialog("Password Change Fail", error.message!, context);
                      }
                    }
                  },
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildLockDesign(){
    return Container(
      margin: EdgeInsets.only(top:140),
      width: width,
      height: height * 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('images/lock.png',height: height* 0.22,width: width*0.5),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  void displayDialog(String title, String message, BuildContext context) {
    var alert = AlertDialog(
      title: Text(title,style: TextStyle(color: (title != 'Password Changed') ? Colors.redAccent : Colors.green)),
      content: Text(message),
      actions: [ElevatedButton(onPressed: (){
        Navigator.pop(context);
      }, child: Text('OK'))],
    );
    showDialog(context: context, builder: (BuildContext context) => alert);
  }
}
