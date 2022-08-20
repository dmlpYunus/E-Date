import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'utils/date_utils.dart' as date_utils ;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class InstructorHomepage extends StatefulWidget {
  const InstructorHomepage({Key? key}) : super(key: key);

  @override
  State<InstructorHomepage> createState() => _InstructorHomepageState();
}

class _InstructorHomepageState extends State<InstructorHomepage> {
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
        body:Stack(
          children: [buildInstructorNotifications(),],
        )

    );
  }

  buildInstructorWelcome() {
    return Container(
      height: height * 0.1,
      width: width,
      color: Colors.blueAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [Text('Welcome')],
      ),
    );
  }

  timeStampToDateTime(Timestamp timeStamp){
    return '${date_utils.DateUtils.fullDayFormat(timeStamp.toDate())} ${timeStamp.toDate().hour.toString()}.00';

  }

  buildInstructorNotifications() {
    return Container(
      margin: EdgeInsets.only(top : height*0.25),
      width: width,
      height: height*0.75,
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: appointments.where('dateTime',isGreaterThanOrEqualTo: DateTime.now()).snapshots(),
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

  buildAppointments() async {
    Query<Map<String, dynamic>> queryDocumentSnapshot = firebaseFirestore
        .collection("appointments")
        .where('instructorId', isEqualTo: 'eGOUMz7bh0hQERLSOYcnxZjQC5j1');
    QuerySnapshot<Map<String, dynamic>> doc = await queryDocumentSnapshot.get();
    return doc;
  }
}
