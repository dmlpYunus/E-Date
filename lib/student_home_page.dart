import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterfirebasedeneme/admin_screen.dart';
import 'package:flutterfirebasedeneme/search_widget.dart';
import 'package:flutterfirebasedeneme/student_account_settings.dart';
import 'package:flutterfirebasedeneme/student_past_appointments_screen.dart';
import 'package:flutterfirebasedeneme/student_upcoming_appointments_screen.dart';
import 'Model/instructor.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/reservation_screen.dart';

import 'instructor_upcoming_appointments_screen.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final textController = TextEditingController();
  AuthService _authService = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  CollectionReference instructorsdb =
  FirebaseFirestore.instance.collection("users");
  String selectedInst = "1234";
  Instructor selected = Instructor();
  late Stream<QuerySnapshot<Object?>> instructorsStream;
  double width = 0;
  double height = 0;
  late bool isAdmin;
  String query = '';

  @override
  void initState() {
    super.initState();
    updateFcmToken();
    instructorsStream = instructorsdb.where('role', isEqualTo: 'instructor')
        .orderBy("name")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery
        .of(context)
        .size
        .height;
    width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text('Home Page',style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        )),
        centerTitle: true,
      ),
      drawer: buildDrawer(),
      body: Stack(
        children: [
          //buildHomepageTopView(),
          buildSearchBar(),
          buildInstructorsList(),
          buildAdminPageButton(),
        ],
      ),
    );
  }

  buildHomepageTopView() {
    return Container(
      width: width,
      height: height * 0.2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [
          IconButton(
              icon: const Icon(Icons.person),
            onPressed: (){
                setState(() {
                  buildDrawer();
                  showDialog(context: context, builder: (context) {
                    return Dialog(
                      child: Text('clicked'),
                    );
                  },);
                });
          },
          ),
          const Text('Homepage',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  buildDrawer() {
    return Drawer(
      width: width * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildUserInfo(),
          buildDrawerButtons()
        ],
      ),
    );
  }

  buildDrawerButtons() {
    return Container(
      width: width * 0.75,
      height: height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                  primary: Colors.black,
                  shadowColor: Colors.transparent,
                  fixedSize: Size.fromWidth(width * 0.5),
                  side: const BorderSide(color: Colors.black,width: 1),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const StudentUpcomingAppointments()));
              },
              child: const Text('Upcoming Appointments',style: TextStyle(fontSize: 14.78))),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                  primary: Colors.black,
                  shadowColor: Colors.transparent,
                  fixedSize: Size.fromWidth(width * 0.5),
                  side: const BorderSide(color: Colors.black,width: 1),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const StudentPastAppointments()));
              },
              child: const Text('Past Appointments',style: TextStyle(fontSize: 14.78))),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                  primary: Colors.black,
                  shadowColor: Colors.transparent,
                  fixedSize: Size.fromWidth(width * 0.5),
                  side: const BorderSide(color: Colors.black,width: 1.2),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StudentAccountSettings()));
              },
              child: const Text('Account Settings',style: TextStyle(fontSize: 15.5))),
        ],
      ),
    );
  }

  buildUserInfo()  {
    return Container(
        width: width * 0.75,
        height: height * 0.3,
        margin: EdgeInsets.only(top:height *0.15),
        child: FutureBuilder(
          future: instructorsdb.doc(_firebaseAuth.currentUser!.uid).get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot>snapshot) {
            if(snapshot.hasData){
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                    Image.asset('images/student.png',height: height*0.15,width: width*0.7),
                    Text('${snapshot.data!.get('name')} ${snapshot.data!.get('surname')}'),
                    Text('${snapshot.data!.get('email')}'),
                    Text(capitalizeFirstLetter(snapshot.data!.get('role')))]
              );
            }else if(snapshot.hasError){
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [Text(snapshot.error.toString()),
                    Text('${snapshot.data!.get('email')}')]);
            } else{
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  const [Text('EMPTY')]);
            }
          },
        )
    );
  }

  buildSearchBar() {
    return Container(
        width: width,
        height: height * 0.1,
        //margin: EdgeInsets.only(top: height * 0.12),
        child: SearchWidget(
          text: query,
          hintText: 'Instructor Name',
          onChanged: searchInstructor,
        )
    );
  }

  buildInstructorsList() {
    return Container(
      height: height * 0.7,
      margin: EdgeInsets.only(top: height * 0.1),
      child: StreamBuilder(
          stream: instructorsStream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                  child: CircularProgressIndicator()
              );
            }
            return ListView(
              children: snapshot.data!.docs.map((instructors) {
                return Center(
                  child: ListTile(
                    onTap: () {
                      selected = buildInstructor(instructors);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                              ReservationPage(
                                  title: selectedInst, instructor: selected)));
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    trailing: const Text('Instructor'),
                    leading: Image.asset(
                        'images/instructor.png', color: Colors.black,
                        scale: 13),
                    subtitle: Text(instructors['email']),
                    title: Text(
                      '${instructors['name']} ${instructors['surname']}',),
                  ),
                );
              }).toList(),
            );
          }),
    );
  }

  buildAdminPageButton() {
    return Container(
      width: width,
      height: height * 0.1,
      margin: EdgeInsets.only(top: height * 0.8),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.black,
                shadowColor: Colors.transparent,
                fixedSize: Size.fromWidth(width * 0.5),
                side: const BorderSide(color: Colors.black,width: 1),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const adminScreen(),));
            },
            child: const Text('Admin Page'),
          ),
        ],
      ),
    );
  }

  void searchInstructor(String query) async {
    setState(() {
      if (query == '') {
        instructorsStream =
            instructorsdb.where('role', isEqualTo: 'instructor').orderBy(
                "search").snapshots();
      } else {
        instructorsStream =
            instructorsdb.where('role', isEqualTo: 'instructor').orderBy(
                "search").startAt([query]).endAt(['$query\uf8ff']).snapshots();
      }
    });
  }

  Instructor buildInstructor(QueryDocumentSnapshot inst) {
   Map<String,dynamic> instMap = inst.data() as Map<String,dynamic>;
   if(instMap.containsKey('fcmToken')){
     print('WİTH FCM');
     return Instructor.withFcm(inst['UID'],
         inst['name'],
         inst['email'],
         inst['surname'], "Computer", inst['fcmToken']);
   }else{
     print('NOT FCM');
     return Instructor.withValues(
         inst['UID'], inst['name'], inst['email'], inst['surname'],
         "Computer");
   }
  }

  void updateFcmToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      //var a = {'fcmToken': value};
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({'fcmToken' : value});
      print('FCM TOKEN UPDATED');
    });
  }

  String capitalizeFirstLetter(String s){
    String capitalizedString = s.characters.first.toUpperCase()+ s.substring(1)  ;
    return capitalizedString;
  }
}

