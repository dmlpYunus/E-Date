import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'utils/date_utils.dart' as date_utils;

class StudentUpcomingAppointments extends StatefulWidget {
  const StudentUpcomingAppointments({Key? key}) : super(key: key);

  @override
  State<StudentUpcomingAppointments> createState() =>
      _StudentUpcomingAppointmentsState();
}

class _StudentUpcomingAppointmentsState extends State<StudentUpcomingAppointments> {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  double width = 0.0;
  double height = 0.0;
  CollectionReference appointments =
  FirebaseFirestore.instance.collection("appointments");
  late Stream<QuerySnapshot<Object?>> appointmentsStream;
  late String status;

  @override
  void initState() {
    super.initState();
      appointmentsStream = appointments
          .where('studentUID',isEqualTo:_firebaseAuth.currentUser!.uid)
          .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
          .orderBy('dateTime', descending: false)
          .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        centerTitle: true,
        title: const Text('Upcoming Appointments',textAlign: TextAlign.center,style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [buildStatusButtons(), buildUpcomingAppointmentsList()],
      ),
    );
  }

  buildStatusButtons(){
    return Container(
      width: width,
      height: height * 0.1,
      //margin: EdgeInsets.only(top : height * 0.12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: (){
                setState(() {
                  status = 'cancelled';
                  appointmentsStream = appointmentsStream = appointments
                      .where('studentUID',isEqualTo:_firebaseAuth.currentUser!.uid)
                      .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
                      .where('status',isEqualTo: status)
                      .orderBy('dateTime', descending: false)
                      .snapshots();
                });
              },
              style: ButtonStyle(side: MaterialStateBorderSide.resolveWith((states) => const BorderSide(color: Colors.black,style: BorderStyle.solid)),
                backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                shadowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
              ),
              child: const Text('Cancelled',style: TextStyle(color: Colors.black),)),
          ElevatedButton(
              onPressed: (){
                setState(() {
                  status = 'Denied';
                  appointmentsStream = appointmentsStream = appointments
                      .where('studentUID',isEqualTo:_firebaseAuth.currentUser!.uid)
                      .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
                      .where('status',isEqualTo: status)
                      .orderBy('dateTime', descending: false)
                      .snapshots();
                });
              },
              style: ButtonStyle(side: MaterialStateBorderSide.resolveWith((states) => const BorderSide(color: Colors.black,style: BorderStyle.solid)),
                backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                shadowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
              ),
              child: const Text('Denied',style: TextStyle(color: Colors.black))),
          ElevatedButton(
              onPressed: (){
                setState(() {
                  status = 'pending';
                  appointmentsStream = appointmentsStream = appointments
                      .where('studentUID',isEqualTo:_firebaseAuth.currentUser!.uid)
                      .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
                      .where('status',isEqualTo: status)
                      .orderBy('dateTime', descending: false)
                      .snapshots();
                });
              },
              style: ButtonStyle(side: MaterialStateBorderSide.resolveWith((states) => const BorderSide(color: Colors.black,style: BorderStyle.solid)),
                backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                shadowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
              ),
              child: const Text('Pending',style: TextStyle(color: Colors.black))),
          ElevatedButton(
              onPressed: (){
                setState(() {
                  status = 'Approved';
                  appointmentsStream = appointmentsStream = appointments
                      .where('studentUID',isEqualTo:_firebaseAuth.currentUser!.uid)
                      .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
                      .where('status',isEqualTo: status)
                      .orderBy('dateTime', descending: false)
                      .snapshots();
                });
              },
              style: ButtonStyle(side: MaterialStateBorderSide.resolveWith((states) => const BorderSide(color: Colors.black,style: BorderStyle.solid)),
                backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                shadowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
              ),
              child: const Text('Accepted',style: TextStyle(color: Colors.black)))
        ],
      ),
    );
  }

  buildUpcomingAppointmentsList() {
    return Container(
      margin: EdgeInsets.only(top: height * 0.1),
      width: width,
      height: height * 0.9,
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: appointmentsStream,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Text("Loading"),
                    );
                  } else {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text("No Appointment Available"),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return ListView(
                        children: snapshot.data!.docs.map((appointments) {
                          return Center(
                            child: ListTile(
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 15),
                              trailing: (appointments['status'] == 'pending') ?
                              const Text('Pending',style : TextStyle(color: Colors.orangeAccent)) :
                              (appointments['status'] == 'Denied') ?
                              const Text('Denied',style : TextStyle(color: Colors.red)) :
                              (appointments['status'] == 'Approved') ?
                              const Text('Approved',style : TextStyle(color: Colors.green)) :
                              const Text('Denied',style : TextStyle(color: Colors.deepPurple)),
                              leading:
                                  Image.asset('images/calendarr.png',scale: 10),
                              //const Icon(Icons.insert_invitation_rounded),
                              subtitle: Text(timeStampToDateTime(
                                  appointments['dateTime'])),
                              title: Text(
                                  '${appointments['instructorName']} ${appointments['instructorSurname']}',
                                  style:  TextStyle(
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 19,
                                    decoration:  (['denied','cancelled'].contains(appointments['status'])) ? TextDecoration.lineThrough : TextDecoration.none
                                )
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  }
                }),
          ),
        ],
      ),
    );
  }

  timeStampToDateTime(Timestamp timeStamp) {
    return '${date_utils.DateUtils.fullDayFormat(timeStamp.toDate())} ${timeStamp.toDate().hour.toString()}.00';
  }
}
