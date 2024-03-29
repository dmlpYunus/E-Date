import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



class AuthService {
  final FirebaseAuth _mauth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signIn(String email, String pass) async {
    var user =
        await _mauth.signInWithEmailAndPassword(email: email, password: pass);
    return user.user;
  }

  Future<User?> signUp(String email, String pass,String name, String surname) async {
    var user = await _mauth.createUserWithEmailAndPassword(
        email: email, password: pass);
    await _firestore.collection("users").doc(user.user?.uid).set(
      {
        'name' : name,
        'surname' : surname,
        'email': email,
        'password': pass,
        'role': 'student',
        'id': email.split('@')[0].toUpperCase(),
        'UID' : user.user?.uid
      },
    );
    return user.user;
  }

  logOut() {
    _mauth.signOut().then((value) => {
       //LoginPage()
    });
  }

   Future<String> getCurrentUserId() async {
     User? user =  _mauth.currentUser;
      return user!.uid;
  }

  getCurrentUserMap()async {
    final docRef = _firestore.collection("users").doc(_mauth.currentUser!.uid);
    docRef.get().then(
          (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        print(data.containsKey('name'));
        print(data['name']);
        return data;
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  Future<Map<String, dynamic>?>? getCurrentUser() async  {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =  await _firestore.collection('users').doc(_mauth.currentUser?.uid).get();
    return documentSnapshot.data();
  }

  getSelectedUser(String uID) async {
    DocumentSnapshot documentSnapshot =  await _firestore.collection('users').doc(uID).get();
    return documentSnapshot.data() as Map;
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
        'id': user.user?.uid.trim(),
        'name': name,
        'surname': surname
      },
    );

    await _firestore.collection("users").doc(user.user?.uid).set(
      {
        'fcmToken' : await FirebaseMessaging.instance.getToken(),
        'name' : name,
        'surname' : surname,
        'email': email,
        'password': pass,
        'role': 'instructor',
        'id': email.split('@')[0].toLowerCase(),
        'UID' : user.user?.uid
      },
    );
    return user.user;
  }

   forgetPassword(String email) async {
    return _mauth.sendPasswordResetEmail(email: email);
  }


}
