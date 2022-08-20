import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'utils/date_utils.dart' as date_utils ;

class AppointmentApproval extends StatefulWidget {
  const AppointmentApproval({Key? key}) : super(key: key);

  @override
  State<AppointmentApproval> createState() => _AppointmentApprovalState();

}

class _AppointmentApprovalState extends State<AppointmentApproval> {
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
        title: Text('Pending Appointment Requests'),
      ),
          body: Stack(
            children: [
              buildPendingAppointmentsList()
            ],
          ),
    );
  }

  buildPendingAppointmentsList(){
    return Container(
      margin: EdgeInsets.only(top : height*0.1),
      width: width,
      height: height*0.5,
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: appointments
                    .where('dateTime',isGreaterThan: DateTime.now())
                    .where('status',isEqualTo: 'pending')
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
                          onTap: (){

                          },
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                          trailing: const Icon(Icons.access_alarm_rounded),
                          leading: const Icon(Icons.insert_invitation_rounded),
                          subtitle: Text(timeStampToDateTime(appointments['dateTime'])),
                          title: Text('${appointments['studentName']} ${appointments['studentSurname']} ${appointments['studentId']}'),
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
