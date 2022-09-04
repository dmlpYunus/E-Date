import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'utils/date_utils.dart' as date_utils ;

class InstPastAppointments extends StatefulWidget {
  const InstPastAppointments({Key? key}) : super(key: key);

  @override
  State<InstPastAppointments> createState() => _InstPastAppointmentsState();

}

class _InstPastAppointmentsState extends State<InstPastAppointments> {
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
        backgroundColor: Colors.redAccent,

        title: Text('Past Appointments'),
      ),
      body: Stack(
        children: [
          buildPastAppointmentsList()
        ],
      ),
    );
  }

  buildPastAppointmentsList() {
    return Container(
      margin: EdgeInsets.only(top: height * 0.1),
      width: width,
      height: height * 0.9,
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: appointments
                    .where('dateTime', isLessThan: DateTime.now())
                //.where('status',isEqualTo: 'pending')
                    .orderBy('dateTime', descending: false)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text("No Appointment Requests Available"),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((appointments) {
                      return Center(
                        child: ListTile(
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                          trailing: const Icon(Icons.access_alarm_rounded),
                          leading:
                          const Icon(Icons.insert_invitation_rounded),
                          subtitle: Text(
                              timeStampToDateTime(appointments['dateTime'])),
                          title: Text(
                              '${appointments['studentName']} ${appointments['studentSurname']} '
                                  '${appointments['studentId']}'),
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
  timeStampToDateTime(Timestamp timeStamp){
    return '${date_utils.DateUtils.fullDayFormat(timeStamp.toDate())} ${timeStamp.toDate().hour.toString()}.00';
  }
}
