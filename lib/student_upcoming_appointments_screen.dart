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
        children: [buildUpcomingAppointmentsList()],
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
                stream: appointments
                    .where('studentUID',isEqualTo:_firebaseAuth.currentUser!.uid)
                    .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
                    .orderBy('dateTime', descending: false)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Text("Loading"),
                    );
                  } else {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text("No Appointment Requests Available"),
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
                              (appointments['status'] == 'denied') ?
                              const Text('Denied',style : TextStyle(color: Colors.red)) :
                              (appointments['status'] == 'accepted') ?
                              const Text('Denied',style : TextStyle(color: Colors.green)) :
                              const Text('Denied',style : TextStyle(color: Colors.deepPurple)),
                              leading:
                              const Icon(Icons.insert_invitation_rounded),
                              subtitle: Text(timeStampToDateTime(
                                  appointments['dateTime'])),
                              title: Text(
                                  '${appointments['instructorName']} ${appointments['instructorSurname']} '
                                      '${appointments['studentId']}'),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  }
                  ;
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
