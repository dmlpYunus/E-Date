import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Model/instructor.dart';
import 'utils/colors_util.dart';
import 'utils/date_utils.dart' as date_util;
import 'package:http/http.dart' as http;

class ReservationPage extends StatefulWidget {
  Instructor instructor;
  String title;
  ReservationPage({Key? key, required this.title, required this.instructor})
      : super(key: key);

  @override
  _ReservationPageState createState() =>
      _ReservationPageState(title, instructor);
}

class _ReservationPageState extends State<ReservationPage> {
  String instName;
  Instructor instructor;
  _ReservationPageState(this.instName, this.instructor);
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late String name, surname, id, email, role,uID;
  late String token;
  double width = 0.0;
  double height = 0.0;
  late ScrollController scrollController;
  late DateTime selectedDateTime;
  late DateTime selectedDay;
  List<DateTime> currentMonthList = List.empty();
  List monthDays = date_util.DateUtils.daysInMonth(DateTime.now());
  late int selectedHourIndex, selectedMonthIndex;
  List<DateTime> instructorAppointmentsList = [];
  DateTime currentDateTime = DateTime.now();
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Stack(
          children: <Widget>[
            titleView(),
            horizontalCapsuleListView(),
            hoursView()
          ],
        ),
        floatingActionButton: (buildHoursList().contains(selectedDateTime)) ? floatingActionBtn() : null,
    );
  }

  @override
  void initState() {
    super.initState();
    currentMonthList = date_util.DateUtils.daysInMonth(currentDateTime);
    currentMonthList.sort((a, b) => a.day.compareTo(b.day));
    scrollController =
        ScrollController(initialScrollOffset: 70.0 * currentDateTime.day + 1);
    selectedDay = DateTime(
        currentDateTime.year, currentDateTime.month, currentDateTime.day);
    print(selectedDay);
    selectedDateTime = DateTime(
        currentDateTime.year, currentDateTime.month, currentDateTime.day);
    getToken();
    getAppointmentTable();
    loadUserData();
  }

  loadUserData() async {
    await _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((snapshot) {
      setState(() {
        email = snapshot.data()!['email'];
        name = snapshot.data()!['name'];
        id = snapshot.data()!['id'];
        uID = snapshot.id;
        surname = snapshot.data()!['surname'];
        role = snapshot.data()!['role'];
      });
    });
  }

  getAppointmentTable() async {
    await _firestore
        .collection('appointments')
        .where('dateTimeDay', isEqualTo: selectedDay)
        .where('instructorId', isEqualTo: instructor.id)
        .where('status',whereNotIn: ['pending','Cancelled','Denied','Declined'])
        .get()
        .then((snapshot) {
      instructorAppointmentsList.clear();
      if (snapshot.size == 0) {
        return;
      }
      for (int i = 0; i < snapshot.size; i++) {
        instructorAppointmentsList
            .add(snapshot.docs[i].get('dateTime').toDate());
      }
    });
  }

  List<DateTime> buildHoursList() {
    List<DateTime> hours = [];
    for (int i = 8; i <= 20; i++) {
      hours.add(selectedDay.add(Duration(hours: i)));
    }
    return hours;
  }

  void hoursViewOnTap(int index) {
    if(buildHoursList()[index].isAfter(DateTime.now())){
      selectedHourIndex = index;
      selectedDateTime =
          selectedDay.add(Duration(hours: buildHoursList()[index].hour));
      print('Selected Day :  $selectedDay');
      print('Selected Time :  $selectedDateTime');
    }
  }

  void montViewOnTap(int index) {
    if(!currentMonthList[index]
        .isBefore(
    (DateTime.now().subtract(Duration(days: 1))))){
      currentDateTime = date_util.DateUtils.daysInMonth(currentDateTime)[index];
      selectedDay = currentDateTime;
      clearDateTime(selectedDay);
      selectedDateTime = selectedDay;
      print('Selected Day :  $selectedDay');
      print('Selected Time :  $selectedDateTime');
      getAppointmentTable();
      buildHoursList();
    }
  }

  Widget hoursView() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, height * 0.28, 15, 15),
      width: width,
      height: height * 0.8,
      child: ListView.builder(
        itemCount: buildHoursList().length - 1,
        itemBuilder: (context, index) {
          return StreamBuilder(
            stream:  _firestore
                .collection('appointments')
                .where('instructorId',
                isEqualTo: instructor.id)
                .where('dateTimeDay', isEqualTo: selectedDay)
                .where('status',whereNotIn: ['Denied','Cancelled'])
                .snapshots(),
            builder: (
                context,
                AsyncSnapshot<QuerySnapshot> snapshot,
                ) {
              return ListTile(
                tileColor: (buildHoursList()[index].isBefore(DateTime.now()))
                    ? Colors.transparent//.withOpacity(0.3)
                    : (selectedDateTime == buildHoursList()[index])
                    ? Colors.blueGrey.withOpacity(0.2)
                    : Colors.transparent,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                  leading: const Icon(
                    Icons.access_time,
                    color: Colors.black,
                    size: 28,
                  ),
                  title: Text(
                      '${buildHoursList()[index].hour}.00 - ${buildHoursList()[index + 1].hour}.00',
                      style:  TextStyle(
                        color: (selectedDateTime == buildHoursList()[index]) ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: (buildHoursList()[index].isBefore(DateTime.now())) ?
                        TextDecoration.lineThrough
                            : TextDecoration.none
                      ),textAlign: TextAlign.justify),

                  trailing: (buildHoursList()[index].isBefore(DateTime.now()))
                      ?
                  Icon(Icons.block_rounded,color: Colors.blueGrey,size: 30)
                  /*const Text(
                      'Invalid',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ))*/ :
                  (snapshot.hasData &&
                      snapshot.data!.docs
                          .where((element) =>
                      buildHoursList()[index] ==
                          (element.get('dateTime').toDate()))
                          .isNotEmpty)
                      ? const Text(
                      'Busy',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ))
                      : const Text(
                      'Free',
              textAlign: TextAlign.justify,
              style: TextStyle(
              color: Colors.green,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              )),
                onTap: (buildHoursList()[index].isAfter(DateTime.now()))
                    ? (){
                  setState(() {
                    hoursViewOnTap(index);
                  });
                } : null,
              );
            },
          );
        },
      ),
    );
  }


  previousMonth() {
    currentDateTime = date_util.DateUtils.previousMonth(currentDateTime);
    currentMonthList = date_util.DateUtils.daysInMonth(currentDateTime);
    selectedDateTime = currentDateTime;
  }

  nextMonth() {
    currentDateTime = date_util.DateUtils.nextMonth(currentDateTime);
    currentMonthList = date_util.DateUtils.daysInMonth(currentDateTime);
    selectedDateTime = currentDateTime;
  }

  Widget titleView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 60, 0, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 30, color: Colors.black),
            onTap: () {
              setState(() {
                previousMonth();
              });
            },
          ),
          const SizedBox(width: 20),
          Text(
            date_util.DateUtils.months[currentDateTime.month - 1] +
                ' ' +
                currentDateTime.year.toString(),
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(width: 20),
          GestureDetector(
              child: const Icon(Icons.arrow_forward_ios,
                  size: 30, color: Colors.black),
              onTap: () {
                setState(() {
                  nextMonth();
                });
              }),
        ],
      ),
    );
  }

  Widget horizontalCapsuleListView() {
    return Container(
      width: width,
      height: 120,
      margin: const EdgeInsets.only(top: 100),
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: date_util.DateUtils.daysInMonth(currentDateTime).length,
        itemBuilder: (BuildContext context, int index) {
          return capsuleView(index);
        },
      ),
    );
  }

  Widget capsuleView(int index) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: GestureDetector(
          onTap: () {
            setState(() {
              montViewOnTap(index);
            });
          },
          child: Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: (currentMonthList[index]
                        .isBefore(
                        (DateTime.now().subtract(Duration(days: 1)))
                    )
                    )
                        ? [
                      Colors.blueGrey.withOpacity(0.3),
                      Colors.blueGrey.withOpacity(0.6),
                      Colors.blueGrey.withOpacity(0.9),
                    ] :
                    (currentMonthList[index].day != currentDateTime.day)
                        ? [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.transparent,
                          ] :  [
                            HexColor('0416B5'),
                            HexColor('0416B5'),
                            HexColor('0416B5'),
                          ],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(0.0, 1.0),
                    stops: const [0.0, 0.5, 1.0],
                    tileMode: TileMode.clamp),
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(2, 2),
                    blurRadius: 2,
                    spreadRadius: 1,
                    color: Colors.transparent,
                  )
                ]),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    currentMonthList[index].day.toString(),
                    style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color:(currentMonthList[index]
                            .isBefore(
                          (DateTime.now().subtract(Duration(days: 1))))) ?
                            Colors.white38:
                             (currentMonthList[index].day != currentDateTime.day)
                                ? Colors.black
                                : Colors.white),
                  ),
                  Text(
                    date_util.DateUtils
                        .weekdays[currentMonthList[index].weekday - 1],
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            (currentMonthList[index].day != currentDateTime.day)
                                ? Colors.blueGrey
                                : Colors.white),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Widget topView() {
    return Container(
      height: height * 0.35,
      width: width,
      decoration:  BoxDecoration(
        gradient: LinearGradient(
            colors: [
              //Colors.blueGrey,
              HexColor("488BC8").withOpacity(0.7),
              HexColor("488BC8").withOpacity(0.5),
              HexColor("488BC8").withOpacity(0.3)
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: [0.0, 0.5, 1.0],
            tileMode: TileMode.clamp),
        boxShadow: const [
          BoxShadow(
              blurRadius: 4,
              //color: Colors.black12,
              color : Colors.transparent,
              offset: Offset(4, 4),
              spreadRadius: 2)
        ],
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        ),
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            titleView(),
            horizontalCapsuleListView(),
          ]),
    );
  }

  Widget floatingActionBtn() {
    return Align(
      alignment: Alignment.bottomRight,
      child: FloatingActionButton(
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: (buildHoursList().contains(selectedDateTime) &&
                          !instructorAppointmentsList
                              .contains(selectedDateTime))
                      ? [
                          Colors.green.withOpacity(0.8),
                          Colors.green.withOpacity(0.9),
                          Colors.green.withOpacity(1)
                        ]
                      : [
                          Colors.red.withOpacity(0.8),
                          Colors.red.withOpacity(0.9),
                          Colors.red.withOpacity(1)
                        ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(0.0, 1.0),
                  stops: const [0.0, 0.5, 1.0],
                  tileMode: TileMode.clamp)),
          child: (buildHoursList().contains(selectedDateTime) &&
                  !instructorAppointmentsList.contains(selectedDateTime))
              ? const Icon(
                  Icons.done_outlined,
                  size: 30,
                )
              : const Icon(
                  Icons.cancel_outlined,
                  size: 30,
                ),
        ),
        onPressed: () {
          if (instructorAppointmentsList
              .contains(buildHoursList()[selectedHourIndex])) {
            displayErrorDialog("Error", "Selected Slot Not Available", context);
          } else {
            createAppointment(selectedDateTime, id, name, surname, instructor);
          }
        },
      ),
    );
  }

  void displaySnackBar(String message) {
    var snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
      ),
      dismissDirection: DismissDirection.down,
      margin: const EdgeInsets.all(10),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.blueAccent,
      duration: const Duration(seconds: 6),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  createAppointment(DateTime dateTime, String studentId, String studentName,
      String studentSurname, Instructor instructor) async {
    Map<String, dynamic> appointment = {};
    appointment['dateTime'] = dateTime;
    appointment['appointmentRegisterTime'] = DateTime.now();
    appointment['dateTimeDay'] = selectedDay;
    appointment['instructorName'] = instructor.name.trim();
    appointment['instructorSurname'] = instructor.surname.trim();
    appointment['instructorId'] = instructor.id;
    appointment['instructorMail'] = instructor.mail;
    appointment['studentId'] = studentId.trim();
    appointment['studentName'] = studentName.trim();
    appointment['studentSurname'] = studentSurname.trim();
    appointment['studentMail'] = email;
    appointment['studentUID'] =  _firebaseAuth.currentUser!.uid.trim();
    appointment['status'] = 'pending';
    await FirebaseFirestore.instance
        .collection('appointments')
        .add(appointment)
        .then((value) {
      displaySuccessfullDialog(
          'Appointment Request Successful', value.id, context);
      sendNotification(token);
    });
  }

  DateTime clearDateTime(DateTime dateTime) {
    dateTime.subtract(Duration(
      hours: dateTime.hour,
      minutes: dateTime.minute,
    ));
    return dateTime;
  }

  void displaySuccessfullDialog(
      String title, String message, BuildContext context) {
    var alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      title: const Text('Appointment Request Successful'),
      content: Container(
        height: height*0.12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appointment ID : $message'),
            const SizedBox(height: 10),
            Text('Date : ${date_util.DateUtils.fullDayFormat(selectedDateTime)} Hour : ${selectedDateTime.hour}:00'),
            const SizedBox(height: 5),
            Text('Instructor : ${instructor.name} ${instructor.surname}'),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
            style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                shadowColor :MaterialStateColor.resolveWith((states) => Colors.transparent) ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Return',style: TextStyle(color: HexColor('0416B5'))))
      ],
    );
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void displayErrorDialog(String title, String message, BuildContext context) {
    var alert = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  getToken() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(instructor.id)
        .get()
        .then((value) {
      token = value.get('fcmToken').toString();
    });
  }

  void sendNotification(String token) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAg6ILid8:APA91bEV1G0iHc580oX91li0Co1qwPiZmOmjCLHMaul4Xa64uPN8IK19XgwLmtruHpk8X8EDGUwSxgnVITWgNwipRBlPuK9JJDJhcUn8YOZoEidHNlhlfhZNLZNqCYZ1QP7d0i2gKSfU'
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': 'You Have An Appointment Request',
              'title': 'Appointment Request'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': token,
          },
        ),
      );
    } catch (e) {
      displayErrorDialog('Error', e.toString(), context);
    }
  }
}
