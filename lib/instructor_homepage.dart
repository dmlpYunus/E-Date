import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebasedeneme/appointment_approval_screen.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/instructor_account_settings_screen.dart';
import 'package:flutterfirebasedeneme/instructor_past_appointments_screen.dart';
import 'package:flutterfirebasedeneme/instructor_upcoming_appointments_screen.dart';
import 'package:flutterfirebasedeneme/utils/colors_util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utils/date_utils.dart' as date_util;

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
  DateTime currentDateTime = DateTime.now();
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
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.black,
          title: const Text('E-Date',style: TextStyle(color: Colors.black,fontSize: 30)),
          centerTitle: true,
          actions: [
            InkWell(
              child: Container(
                  padding: const EdgeInsets.all(5),
                  child: const Icon(Icons.notifications,color: Colors.black,)),
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

  @override
  void initState() {
    super.initState();
    updateFcmToken();
    today =
        //DateTime.utc(DateTime.now().year,DateTime.now().month,DateTime.now().day);
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().add(const Duration(hours: 3)).day);
  }

  buildInstructorWelcome() {
    return Container(
      height: height * 0.1,
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [Text('Welcome',style: TextStyle(fontSize: 24,color: Colors.blue,fontWeight: FontWeight.bold)),
          Text('Today\'s appointments',style: TextStyle(fontSize: 18,color: Colors.deepOrangeAccent,fontWeight: FontWeight.normal))],
      ),
    );
  }

  timeStampToDateTime(Timestamp timeStamp) {
    return '${date_util.DateUtils.fullDayFormat(timeStamp.toDate())} ${timeStamp.toDate().hour.toString()}.00';
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

  Widget hoursView() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, height * 0.1, 15, 15),
      width: width,
      height: height * 0.90,
      child: ListView.builder(
        itemCount: buildHoursList().length - 1,
        itemBuilder: (context, index) {
          return StreamBuilder(
            stream:  _firestore
                .collection('appointments')
                .where('instructorId',
                    isEqualTo: _firebaseAuth.currentUser!.uid)
                .where('dateTimeDay', isEqualTo: today)
                .where('status',isEqualTo: 'Approved')
                .snapshots(),
            builder: (
              context,
              AsyncSnapshot<QuerySnapshot> snapshot,
            ) {
              return ListTile(
                onTap: (){
                  List<QueryDocumentSnapshot<Object?>> tile =snapshot.data!.docs
                      .where((element) =>
                  buildHoursList()[index] ==
                      (element.get('dateTime').toDate())).toList();
                 if(tile.isNotEmpty){
                   setState(() {
                     appointmentOnTap(tile.first);
                   });
                 }
                },
                  leading: (buildHoursList()[index].hour == 8)
                      ? Text(
                          '${buildHoursList()[index].hour}.00 - ${buildHoursList()[index + 1].hour}.00      ',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ))
                      : (buildHoursList()[index].hour == 9)
                          ? Text(
                              '${buildHoursList()[index].hour}.00 - ${buildHoursList()[index + 1].hour}.00    ',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ))
                          : Text(
                              '${buildHoursList()[index].hour}.00 - ${buildHoursList()[index + 1].hour}.00 ',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
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
                          style:  TextStyle(
                            color: HexColor('0416B5'),
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

  appointmentOnTap(QueryDocumentSnapshot appointment){
    showDialog(
        context: context,
        builder: (BuildContext context) {
         return approvedDialog(appointment);
        });
  }

  approvedDialog(QueryDocumentSnapshot appointment){
    Map<String,dynamic> appointmentMap = appointment.data() as Map<String,dynamic>;
    if(appointmentMap.containsKey('zoomLink')){
      return  Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: height*0.53,
          width: 450,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              SizedBox(height: height * 0.03),
              const Text('Appointment Details',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
              SizedBox(
                height: height * 0.02,
              ),
              Text(
                "Appointment ID : ${appointment.id}",
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Text('Appointment Date : ${date_util.DateUtils.apiDayFormat(appointment['dateTime'].toDate())}',
                style: const TextStyle(color: Colors.black,fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Text('Time Slot : ${appointment['dateTime'].toDate().hour}:00',
                style: const TextStyle(color: Colors.black,fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Text('Instructor : ${appointment['instructorName']} ${appointment['instructorSurname']}',
                style: const TextStyle(color: Colors.black),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Text('Student ID : ${appointment['studentId']}',
                style: const TextStyle(color: Colors.black),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Text('Student : ${appointment['studentName']} ${appointment['studentSurname']}',
                style: const TextStyle(color: Colors.black),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Text('Student Mail : ${appointment['studentMail']}',
                style: const TextStyle(color: Colors.black),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Text('Zoom Link : ${appointment['zoomLink']}',
                style: const TextStyle(color: Colors.black),
              ),
              SizedBox(
                width: 320,
                child:
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children : [
                      ElevatedButton(  //OK
                        onPressed: () => launchUrl(Uri.parse(appointment['zoomLink']),mode: LaunchMode.externalNonBrowserApplication),
                        style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                            shadowColor :MaterialStateColor.resolveWith((states) => Colors.transparent) ),
                        child: const Text("Launch Meeting",style: TextStyle(color: Colors.green)),
                      ),
                      ElevatedButton(  //OK
                        onPressed: () => Navigator.pop(context),
                        style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                            shadowColor :MaterialStateColor.resolveWith((states) => Colors.transparent) ),
                        child: const Text("Ok",style: TextStyle(color: Colors.blue)),
                      )],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }else{
      return  Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: height*0.44,
          width: 450,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              SizedBox(height: height * 0.03),
              const Text('Appointment Details',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
              SizedBox(
                height: height * 0.02,
              ),
              Text(
                "Appointment ID : ${appointment.id}",
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Text('Appointment Date : ${date_util.DateUtils.apiDayFormat(appointment['dateTime'].toDate())}',
                style: const TextStyle(color: Colors.black,fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Text('Time Slot : ${appointment['dateTime'].toDate().hour}:00',
                style: const TextStyle(color: Colors.black,fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Text('Instructor : ${appointment['instructorName']} ${appointment['instructorSurname']}',
                style: const TextStyle(color: Colors.black),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Text('Student ID : ${appointment['studentId']}',
                style: const TextStyle(color: Colors.black),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Text('Student : ${appointment['studentName']} ${appointment['studentSurname']}',
                style: const TextStyle(color: Colors.black),
              ),
              SizedBox(
                height: height * 0.02,
              ),Text('Student Mail : ${appointment['studentMail']}',
                style: const TextStyle(color: Colors.black),
              ),
              SizedBox(
                width: 320,
                child:
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children : [
                      ElevatedButton(  //OK
                        onPressed: () => Navigator.pop(context),
                        style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                            shadowColor :MaterialStateColor.resolveWith((states) => Colors.transparent)),
                        child: const Text("Ok",style: TextStyle(color: Colors.blue)),
                      )],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
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
        margin: EdgeInsets.only(top:height *0.15),
        child: FutureBuilder(
          future: _firestore.collection('users').doc(_firebaseAuth.currentUser!.uid).get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot>snapshot) {
            if(snapshot.hasData){
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                    Image.asset('images/instructor.png',height: height*0.15,width: width*0.7),
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
                  side: const BorderSide(color: Colors.black,width: 1.2),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InstPastAppointments()));
              },
              child: const Text('Past Appointments',style: TextStyle(fontSize: 15.5))),
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
                        const InstUpcomingAppointments()));
              },
              child: const Text('Upcoming Appointments',style: TextStyle(fontSize: 14.78))),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                  primary: Colors.black,
                  shadowColor: Colors.transparent,
                  fixedSize: Size.fromWidth(width * 0.5),
                  side: const BorderSide(color: Colors.black,width: 1.5),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const InstructorAccountSettings()));
              },
              child: const Text('Account Settings',style: TextStyle(fontSize: 15.5)))
        ],
      ),
    );
  }

  String capitalizeFirstLetter(String s){
    String capitalizedString = s.characters.first.toUpperCase()+ s.substring(1)  ;
    return capitalizedString;
  }

  List<DateTime> buildHoursList() {
    List<DateTime> hours = [];
    for (int i = 8; i <= 20; i++) {
      hours.add(today.add(Duration(hours: i)));
    }
    return hours;
  }


  void updateFcmToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({'fcmToken' : value});
      print('FCM TOKEN UPDATED');
    });
  }
}
