import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebasedeneme/login_screen.dart';


class AuthService {
  final FirebaseAuth _mauth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signIn(String email, String pass) async {
    var user =
        await _mauth.signInWithEmailAndPassword(email: email, password: pass);
    return user.user;
  }

  Future<User?> signUp(String email, String pass) async {
    var user = await _mauth.createUserWithEmailAndPassword(
        email: email, password: pass);
    await _firestore.collection("users").doc(user.user?.uid).set(
      {
        'email': email,
        'password': pass,
        'role': 'student',
        'studentId': email.split('@')[0]
      },
    );
    return user.user;
  }

  logOut() {
    _mauth.signOut().then((value) => {
       LoginPage()
    });
  }

   Future<String> getCurrentUserId() async {
     User? user = await _mauth.currentUser;
      return user!.uid;
  }

  getCurrentUser() async {
    DocumentSnapshot documentSnapshot =  await _firestore.collection('users').doc(_mauth.currentUser?.uid).get();
    return documentSnapshot.data();
  }

  Future<String> getCurrentUserRole() async {
    final uid = await getCurrentUserId();
    DocumentSnapshot snapshot =
    await _firestore.collection('users').doc(uid).get();
    var userType = snapshot.get('role');
    return userType;
  }


  Future<User?> RegisterInstructor(
      String email, String pass, String name, String surname) async {
    var user = await _mauth.createUserWithEmailAndPassword(
        email: email, password: pass);
    await _firestore.collection("instructors").doc(user.user?.uid).set(
      {
        'email': email,
        'password': pass,
        'role': 'instructor',
        'id': user.user?.uid,
        'name': name,
        'surname': surname
      },
    );
    return user.user;
  }

  forgetPassword(String email) {
    _mauth.sendPasswordResetEmail(email: email);
  }
}
