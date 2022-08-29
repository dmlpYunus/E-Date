import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_screen.dart';

class InstructorAccountSettings extends StatefulWidget {
  const InstructorAccountSettings({Key? key}) : super(key: key);

  @override
  State<InstructorAccountSettings> createState() => _InstructorAccountSettingsState();
}

class _InstructorAccountSettingsState extends State<InstructorAccountSettings> {
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            const Center(
              child: Text('Instructor Account Settings'),
            ),
            ElevatedButton(onPressed: (){
              authService.logOut();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            }, child: const Text('LogOut'))
          ],
        ),
    );
  }
}
