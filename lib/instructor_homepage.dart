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
  List<dynamic> instructorAppointmentsList = [];
  List<DateTime> todaysAppointmentHours = [];
  late final currentUser;
  AuthService authService = AuthService();
  late DateTime today;
  double width = 0.0;
  double height = 0.0;
  CollectionReference appointments =
      FirebaseFirestore.instance.collection("appointments");
  @override
  void initState() {
    super.initState();
    today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    getAppointmentTable();
  }

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

  buildAppointments() async {
    Query<Map<String, dynamic>> queryDocumentSnapshot = _firestore
        .collection("appointments")
        .where('instructorId', isEqualTo: await authService.getCurrentUserId())
        .where('dateTime', isEqualTo: DateTime.now());
    QuerySnapshot<Map<String, dynamic>> doc = await queryDocumentSnapshot.get();
    return doc;
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

  buildUserInfo() {
    return Container(
        width: width * 0.75,
        height: height * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Text('Ali Huzur'), Text('alihuzur@isikun.edu.tr')],
        ));
  }

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
                .where('dateTimeDay', isEqualTo: today)
                .snapshots(),
            builder: (context, snapshot) {
              return const ListTile(

              );
            },
          );

          /*ListTile(
            title: (
                ((!todaysAppointmentHours.contains(buildHoursList()[index]))))
              ? Text(
                '${buildHoursList()[index].hour}.00 - ${buildHoursList()[index + 1].hour}.00',
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ))
                :
                Text('${buildHoursList()[index].hour}.00 - ${buildHoursList()[index + 1].hour}.00'),
            autofocus: true,
            contentPadding: const EdgeInsets.only(right: 15, left: 15),
            leading: const Icon(
              Icons.access_time,
              color: Colors.grey,
              size: 28,
            ),
           /* trailing: (instructorAppointmentsList
                .contains(buildHoursList()[index]))
                ? const Text("Busy", style: TextStyle(color: Colors.redAccent))
                : const Text("Free", style: TextStyle(color: Colors.green)),*/
            shape: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.2)),
                bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
            onTap: () {
              setState(() {
                //hoursViewOnTap(index);
              });
            },
          );*/
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
