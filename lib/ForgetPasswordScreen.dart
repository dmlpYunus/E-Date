import 'package:flutter/material.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/login_validator.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);
  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPage();
}

class _ForgetPasswordPage extends State<ForgetPasswordPage> with AccountValidationMixin {
  AuthService authService = AuthService();
  final emailEditor = TextEditingController();
  late double height,width;
  late String _forgetEmail;

  var key = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 10,
        automaticallyImplyLeading: true,
        title: Text('FORGOT PASSWORD?',style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 24
        )),
        leading: IconButton(onPressed: () =>Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_outlined),color: Colors.black),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          buildSplashImage(),buildEmailFormField(),buildSubmitButton()
        ],
      ),
    );
  }

  buildSplashImage(){
    return Container(
      width: width,
        margin: EdgeInsets.only(top: height * 0.15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
            children: [Image.asset('images/pass_forget.png',scale: 3)]));
  }

  buildEmailFormField(){
    return Container(
      width: width,
      margin: EdgeInsets.only(top: height * 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding:  EdgeInsets.only(right: width * 0.05,left:width * 0.05),
            child: Form(
              key: key,
              child: TextFormField(
                controller: emailEditor,
                keyboardType: TextInputType.emailAddress,
                validator: validateMail,
                decoration: const InputDecoration(
                  focusedBorder:OutlineInputBorder(borderSide: BorderSide(color: Colors.black),borderRadius: BorderRadius.all(Radius.circular(30))) ,
                  labelText: ("E-Mail"), hintText: ("xxxx@isik.edu.tr"),
                  prefixIcon: Icon(Icons.mail),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(color: Colors.black))),
                  onSaved: (value){
                  _forgetEmail = value!;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildSubmitButton(){
    return Container(
      margin: EdgeInsets.only(top: height * 0.62),
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OutlinedButton(
            style:  OutlinedButton.styleFrom(
              shadowColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              primary: Colors.black,
              side: BorderSide(color: Colors.black)
            ) ,
            onPressed: () {
              if (key.currentState!.validate()) {
                key.currentState!.save();
                authService.forgetPassword(_forgetEmail);
                //Navigator.push(context, MaterialPageRoute(builder : (context) => MyApp()));
              }
            },
            child: Text("Send E-mail"),
          ),
        ],
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
/* body: Form(
        key: key,
        child: Padding(
          padding: EdgeInsets.only(left:30,right: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/student.png',scale: 3),
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
                child: Text("Send E-mail"),
              ),
            ],
          ),
        ),
      ),*/
