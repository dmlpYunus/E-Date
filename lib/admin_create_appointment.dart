import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterfirebasedeneme/search_widget.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'Model/instructor.dart';
import 'utils/date_utils.dart' as date_util;
import 'package:http/http.dart' as http;
import 'utils/colors_util.dart';


class AdminCreateAppointment extends StatefulWidget {
  const AdminCreateAppointment({Key? key}) : super(key: key);
  @override
  State<AdminCreateAppointment> createState() => _AdminCreateAppointmentState();
}

class _AdminCreateAppointmentState extends State<AdminCreateAppointment>{
  final textController = TextEditingController();
  final AuthService _authService = AuthService();
  CollectionReference studentsdb =
  FirebaseFirestore.instance.collection("users");
  CollectionReference instructorsdb =
  FirebaseFirestore.instance.collection("instructors");
  late Stream<QuerySnapshot<Object?>> studentsStream,instructorsStream,selectedStream;
  double width = 0;
  double height =0;
  String query = '';
  late String title;
  late bool studentSelected;
  late bool instructorSelected;
  late Map<String,dynamic> selectedStudent,selectedInstructor;

  late String instName;
  late Instructor instructor;
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late String name, surname, id, email, role,uID;
  late String token;
  late ScrollController scrollController;
  late DateTime selectedDateTime;
  late DateTime selectedDay;
  List<DateTime> currentMonthList = List.empty();
  List monthDays = date_util.DateUtils.daysInMonth(DateTime.now());
  late int selectedHourIndex, selectedMonthIndex;
  List<DateTime> instructorAppointmentsList = [];
  DateTime currentDateTime = DateTime.now();
  List<String> todos = <String>[];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    title = 'Select Student';
    studentSelected = false;
    instructorSelected = false;
    studentsStream = studentsdb.where('role',isEqualTo: 'student').snapshots();
    instructorsStream = instructorsdb.orderBy("name").snapshots();
    selectedStream = studentsStream;
    currentMonthList = date_util.DateUtils.daysInMonth(currentDateTime);
    currentMonthList.sort((a, b) => a.day.compareTo(b.day));
    scrollController =
        ScrollController(initialScrollOffset: 70.0 * currentDateTime.day + 1);
    selectedDay = DateTime(
        currentDateTime.year, currentDateTime.month, currentDateTime.day);
    selectedDateTime = DateTime(
        currentDateTime.year, currentDateTime.month, currentDateTime.day);
  }

  getAppointmentTable() async {
    await _firestore
        .collection('appointments')
        .where('dateTimeDay', isEqualTo: selectedDay)
        .where('instructorId', isEqualTo:selectedInstructor['id'])
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

  @override
  Widget build(BuildContext context){
    height  = MediaQuery.of(context).size.height;
    width  = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar:(!instructorSelected) ? AppBar(
        backgroundColor:Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        actions: (studentSelected) ? [IconButton(
          onPressed: () => setState(() {
          studentSelected = false;
          selectedStream = studentsStream;
          title = 'Select Student';
          query = '';
        }),
        icon: const Icon(Icons.cancel_rounded,color: Colors.black,))] : [],
        title: Text(title,style: TextStyle(color: Colors.black)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new,color: Colors.black),
        ),

      ) : null ,
      body:Stack(
        children: (!instructorSelected) ? [
          //buildPageTopView(),
          buildUserList(),
          buildSearchBar(),
        ] : [
          titleView(),
          horizontalCapsuleListView(),
          hoursView()
        ],
      ) ,
      floatingActionButton: (instructorSelected) ? floatingActionBtn() :null,
    );
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
                isEqualTo: selectedInstructor['id'])
                .where('dateTimeDay', isEqualTo: selectedDay)
                .where('status',whereNotIn: ['denied','cancelled'])
                .snapshots(),
            builder: (
                context,
                AsyncSnapshot<QuerySnapshot> snapshot,
                ) {
              return ListTile(
                tileColor: (selectedDateTime == buildHoursList()[index]) ? Colors.blueGrey.withOpacity(0.2) : Colors.transparent,
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
                    ),textAlign: TextAlign.justify),
                trailing: (snapshot.hasData &&
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
                onTap: (){
                  setState(() {
                    hoursViewOnTap(index);
                  });
                },
              );
            },
          );
        },
      ),
    );
  }

  void hoursViewOnTap(int index) {
    selectedHourIndex = index;
    selectedDateTime =
        selectedDay.add(Duration(hours: buildHoursList()[index].hour));
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


  void montViewOnTap(int index) {
    currentDateTime = date_util.DateUtils.daysInMonth(currentDateTime)[index];
    selectedDay = currentDateTime;
    clearDateTime(selectedDay);
    selectedDateTime = selectedDay;
    getAppointmentTable();
    buildHoursList();
  }

  List<DateTime> buildHoursList() {
    List<DateTime> hours = [];
    for (int i = 8; i <= 20; i++) {
      hours.add(selectedDay.add(Duration(hours: i)));
    }
    return hours;
  }


  DateTime clearDateTime(DateTime dateTime) {
    dateTime.subtract(Duration(
      hours: dateTime.hour,
      minutes: dateTime.minute,
    ));
    return dateTime;
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
                    colors: (currentMonthList[index].day != currentDateTime.day)
                        ? [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.transparent,
                    ]
                        : [
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
                        color:
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

  buildSearchBar(){
    return Container(
        width: width,
        height: height * 0.1,
        child: SearchWidget(
          text: query,
          hintText: (studentSelected) ? 'Instructor Name' : 'Student Name',
          onChanged: search,
        )
    );
  }

  void search(String query) async{
    setState(()  {
      if(query == ''){
        if(studentSelected){
          selectedStream = instructorsdb.orderBy("name").snapshots();
        }else{
          selectedStream = studentsdb.where('role',isEqualTo: 'student').snapshots();
        }
      }else{
        if(studentSelected){
          selectedStream = instructorsdb.orderBy("search").startAt([query]).endAt(['$query\uf8ff']).snapshots();
        }else{
          selectedStream = studentsdb.where('role',isEqualTo: 'student').orderBy('search').startAt([query]).endAt(['$query\uf8ff']).snapshots();
        }
      }
    });
  }


  buildUserList(){
    return Container(
      height: height*0.8,
      margin: EdgeInsets.only(top: height * 0.1),
      child: StreamBuilder(
          stream:selectedStream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData) {
              return const Center(
                  child: Text('User Not Found')
              );
            }
            return ListView(
              children: snapshot.data!.docs.map((person) {
                return Center(
                  child: ListTile(
                    onTap: () => listTileOnTap(person),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    trailing: (person['role'] == 'instructor') ? Text('Instructor') : Text('Student'),
                    leading: (person['role'] == 'instructor')
                        ? Image.asset('images/instructor.png',color: Colors.black,scale: 13)
                        : Image.asset('images/student.png',color: Colors.black,scale: 13) ,
                    subtitle: Text(person['email']),
                    title: Text('${person['name']} ${person['surname']}',),
                  ),
                );
              }).toList(),
            );
          }),
    );
  }

  void listTileOnTap(QueryDocumentSnapshot student) async {
    setState(() {
      if(studentSelected){
        instructorSelected = true;
        buildSelectedInstructor(student);
      }else{
        studentSelected = true;
        selectedStream = instructorsStream;
        title = 'Select Instructor';
        query = '';
        buildSelectedStudent(student);
      }
    });
  }


  buildSelectedStudent(QueryDocumentSnapshot student) async {
    selectedStudent =  student.data() as Map<String,dynamic>;
    print(selectedStudent);
  }

  buildSelectedInstructor(QueryDocumentSnapshot instructor) async {
    selectedInstructor = instructor.data() as Map<String,dynamic>;
    print(selectedInstructor);
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
          //Navigator.push(context, MaterialPageRoute(builder: (context) => InstructorHomepage()));
          if (instructorAppointmentsList
              .contains(buildHoursList()[selectedHourIndex])) {
            displayErrorDialog("Error", "Selected Slot Not Available", context);
          } else {
            createAppointment(selectedDateTime);
          }
        },
      ),
    );
  }

  createAppointment(DateTime dateTime) async {
    Map<String, dynamic> appointment = {};
    appointment['dateTime'] = dateTime;
    appointment['appointmentRegisterTime'] = DateTime.now();
    appointment['dateTimeDay'] = selectedDay;
    appointment['instructorName'] = selectedInstructor['name'];
    appointment['instructorSurname'] = selectedInstructor['surname'];
    appointment['instructorId'] = selectedInstructor['id'];
    appointment['instructorMail'] = selectedInstructor['mail'];
    appointment['studentId'] = selectedStudent['id'];
    appointment['studentName'] = selectedStudent['name'];
    appointment['studentSurname'] = selectedStudent['surname'];
    appointment['studentMail'] = selectedStudent['mail'];
    appointment['studentUID'] =  selectedStudent['UID'];
    appointment['status'] = 'pending';
    await FirebaseFirestore.instance
        .collection('appointments')
        .add(appointment)
        .then((value)  => displaySuccessfullDialog(
        'Appointment Request Sent To ${selectedInstructor['name']} ${selectedInstructor['surname']}',
            '${date_util.DateUtils.apiDayFormat(dateTime)} \n appointmentId : ${value.id}',
        context)
    );

    //sendNotification(token);
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

  void displaySuccessfullDialog(
      String title, String message, BuildContext context) {
    var alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OKAY'))
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


  buildPageTopView(){
    return Container(
      width: width,
      height: height * 0.2,
      child: Row(
        children: [
          SizedBox(width: width*0.04),
          GestureDetector(
            child: const Icon(Icons.arrow_back_ios_new_outlined,size: 30),
            onTap: (){
              Navigator.pop(context);
            },
          ),
          SizedBox(width: width*0.38),
           Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              )),
          SizedBox(width: width*0.1),
          Visibility(
            visible: studentSelected,
              child: IconButton(
                  onPressed: () => setState(() {
                    studentSelected = false;
                    selectedStream = studentsStream;
                    title = 'Select Student';
                    query = '';
                  }),
                  icon: const Icon(Icons.cancel_rounded)))
        ],
      ),
    );
  }
}



