import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebasedeneme/appointment_approval_screen.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/instructor_account_settings_screen.dart';
import 'package:flutterfirebasedeneme/instructor_past_appointments_screen.dart';
import 'package:flutterfirebasedeneme/instructor_upcoming_appointments_screen.dart';
import 'utils/date_utils.dart' as date_utils;

class InstructorHomepage extends StatefulWidget {
  const InstructorHomepage({Key? key}) : super(key: key);

  @override
  State<InstructorHomepage> createState() => _InstructorHomepageState();
}

class _InstructorHomepageState extends State<InstructorHomepage> {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  AuthService authService = AuthService();
  List<dynamic> instructorAppointmentsList = [];
  List<DateTime> todaysAppointmentHours = [];
  late var currentUser;
  late DateTime today;
  double width = 0.0;
  double height = 0.0;
  CollectionReference appointments =
      FirebaseFirestore.instance.collection("appointments");

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: const Text('E-Date'),
          centerTitle: true,
          actions: [
            InkWell(
              child: Container(
                  padding: const EdgeInsets.all(5),
                  child: const Icon(Icons.notifications)),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AppointmentApproval()));
              },
            ),
          ],
        ),
        drawer: buildDrawer(),
        body: Stack(
          children: [
            /*buildInstructorNotifications()*/ buildInstructorWelcome(),
            hoursView()
          ],
        ));
  }

  buildInstructorWelcome() {
    return Container(
      height: height * 0.1,
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [Text('Welcome'), Text('Today\'s appointments')],
      ),
    );
  }



  timeStampToDateTime(Timestamp timeStamp) {
    return '${date_utils.DateUtils.fullDayFormat(timeStamp.toDate())} ${timeStamp.toDate().hour.toString()}.00';
  }

  buildInstructorNotifications() {
    return Container(
      margin: EdgeInsets.only(top: height * 0.1),
      width: width,
      height: height * 0.5,
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: appointments
                    .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text("Loading..."),
                    );
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((appointments) {
                      return Center(
                        child: ListTile(
                          onTap: () {},
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 15),
                          trailing: const Icon(Icons.access_alarm_rounded),
                          leading: const Icon(Icons.insert_invitation_rounded),
                          subtitle: Text(
                              timeStampToDateTime(appointments['dateTime'])),
                          title: Text(
                              '${appointments['studentName']} ${appointments['studentSurname']} ${appointments['studentId']}'),
                        ),
                      );
                    }).toList(),
                  );
                }),
          ),
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
          buildDrawerButtons(),
        ],
      ),
    );
  }

  buildUserInfo()  {
    return Container(
        width: width * 0.75,
        height: height * 0.2,
        child: FutureBuilder(
          future: _firestore.collection('users').doc(_firebaseAuth.currentUser!.uid).get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot>snapshot) {
            if(snapshot.hasData){
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [Text('${snapshot.data!.get('email')}'),
                  Text('${snapshot.data!.get('role')}')]
              );
            }else if(snapshot.hasError){
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [Text('${snapshot.error.toString()}'),
            Text('${snapshot.data!.get('email')}')]);
            } else{
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [Text('EMPTY')]);
            }
          },
        )
    );
  }


  /*buildUserInfo()  {
    return Container(
        width: width * 0.75,
        height: height * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Text('${currentUser['email']}'), Text('alihuzur@isikun.edu.tr')],
        ));
  }*/

  List<DateTime> buildHoursList() {
    List<DateTime> hours = [];
    for (int i = 8; i <= 20; i++) {
      hours.add(today.add(Duration(hours: i)));
    }
    return hours;
  }

  getAppointmentTable() async {
    print(_firebaseAuth.currentUser!.uid);
    await _firestore
        .collection('appointments')
        .where('dateTimeDay', isEqualTo: today)
        //.where('instructorId', isEqualTo:_firebaseAuth.currentUser!.uid)
        .get()
        .then((snapshot) {
      print(snapshot.size);
      print(snapshot.docs.first.data());
      //print(snapshot.docs.asMap().);
      instructorAppointmentsList.clear();
      if (snapshot.size == 0) {
        return;
      }
      for (int i = 0; i < snapshot.size; i++) {
        instructorAppointmentsList.add(snapshot.docs[i].data());
        print(snapshot.docs[i].get('dateTime'));
        todaysAppointmentHours.add(snapshot.docs[i].get('dateTime').toDate());
      }
    });
  }

  @override
  void initState() {
    super.initState();
    today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    getAppointmentTable();
    currentUser =  authService.getCurrentUser();
  }


  Widget hoursView() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, height * 0.1, 15, 15),
      width: width,
      height: height * 0.90,
      child: ListView.builder(
        itemCount: buildHoursList().length - 1,
        itemBuilder: (context, index) {
          return StreamBuilder(
            stream: _firestore
                .collection('appointments')
                .where('instructorId',
                    isEqualTo: _firebaseAuth.currentUser!.uid)
                .where('dateTimeDay', isEqualTo: today)
                .snapshots(),
            builder: (
              context,
              AsyncSnapshot<QuerySnapshot> snapshot,
            ) {
              return ListTile(
                  leading: (buildHoursList()[index].hour == 8)
                      ? Text(
                          '${buildHoursList()[index].hour}.00 - ${buildHoursList()[index + 1].hour}.00      ',
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ))
                      : (buildHoursList()[index].hour == 9)
                          ? Text(
                              '${buildHoursList()[index].hour}.00 - ${buildHoursList()[index + 1].hour}.00    ',
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ))
                          : Text(
                              '${buildHoursList()[index].hour}.00 - ${buildHoursList()[index + 1].hour}.00 ',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.68),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                  title: (snapshot.hasData &&
                          snapshot.data!.docs
                              .where((element) =>
                                  buildHoursList()[index] ==
                                  (element.get('dateTime').toDate()))
                              .isNotEmpty)
                      ? Text(
                          snapshot.data!.docs
                              .where((element) =>
                                  buildHoursList()[index] ==
                                  (element.get('dateTime').toDate()))
                              .first
                              .get('studentName'),
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ))
                      : const Text('Available',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          )),
                  subtitle: (snapshot.hasData &&
                          snapshot.data!.docs
                              .where((element) =>
                                  buildHoursList()[index] ==
                                  (element.get('dateTime').toDate()))
                              .isNotEmpty)
                      ? Text(
                          snapshot.data!.docs
                              .where((element) =>
                                  buildHoursList()[index] ==
                                  (element.get('dateTime').toDate()))
                              .first
                              .get('studentId'),
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ))
                      : const Text(''));
            },
          );
        },
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
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InstPastAppointments()));
              },
              child: const Text('Past Appointments')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const InstUpcomingAppointments()));
              },
              child: const Text('Upcoming Appointments')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const InstructorAccountSettings()));
              },
              child: const Text('Account Settings'))
        ],
      ),
    );
  }
}
