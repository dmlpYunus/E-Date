import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'utils/date_utils.dart' as date_utils;

class InstUpcomingAppointments extends StatefulWidget {
  const InstUpcomingAppointments({Key? key}) : super(key: key);

  @override
  State<InstUpcomingAppointments> createState() =>
      _InstUpcomingAppointmentState();
}

class _InstUpcomingAppointmentState extends State<InstUpcomingAppointments> {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
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
                    .where('dateTime', isGreaterThan: DateTime.now())
                    .where('status', isEqualTo: 'Approved')
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
                              trailing: const Icon(Icons.done_outline_rounded,color: Colors.green,),
                              leading:
                                   Image.asset('images/calendar.png'),
                              subtitle: Text(timeStampToDateTime(
                                  appointments['dateTime'])),
                              title: Text(
                                  '${appointments['studentName']} ${appointments['studentSurname']} '
                                  '${appointments['studentId']}',overflow: TextOverflow.visible,style: TextStyle(
                                fontWeight: FontWeight.w600
                              )),
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
