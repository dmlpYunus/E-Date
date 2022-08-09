import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService{
  final FirebaseAuth _mauth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signIn(String email, String pass) async{
    var user = await _mauth.signInWithEmailAndPassword(email: email, password: pass);
    return user.user;
  }


  Future<User?> signUp(String email, String pass) async{
    var user = await _mauth.createUserWithEmailAndPassword(email: email, password: pass);
    await _firestore.collection("users").doc(user.user?.uid).set({'email' : email, 'password' : pass});
    return user.user;
  }

   logOut(){
    _mauth.signOut().then((value) => {
    print('Logged OUT!!!')
    });
  }

  forgetPassword(String email){
    _mauth.sendPasswordResetEmail(email: email);
  }



}