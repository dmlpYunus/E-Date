import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebasedeneme/search_widget.dart';
import 'utils/date_utils.dart' as date_utils ;

class InstPastAppointments extends StatefulWidget {
  const InstPastAppointments({Key? key}) : super(key: key);

  @override
  State<InstPastAppointments> createState() => _InstPastAppointmentsState();

}

class _InstPastAppointmentsState extends State<InstPastAppointments> {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  double width = 0.0;
  double height = 0.0;
  CollectionReference appointments =
  FirebaseFirestore.instance.collection("appointments");
  late Stream<QuerySnapshot<Object?>> appointmentStream;
  String query ='';

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded),onPressed: () =>Navigator.pop(context)),
        title: const Text('Past Appointments'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          buildSearchBar(),buildPastAppointmentsList()
        ],
      ),
    );
  }


  @override
  void initState() {
    appointmentStream =
        appointments.where('instructorId', isEqualTo: firebaseAuth.currentUser!.uid)
            .where('status', isEqualTo: 'Approved')
            .where('dateTime',isLessThan: DateTime.now())
            .orderBy('dateTime', descending: false)
            .snapshots();
  }

  buildSearchBar() {
    return Container(
        width: width,
        height: height * 0.1,
        //margin: EdgeInsets.only(top: height * 0.12),
        child: SearchWidget(
          text: query,
          hintText: 'Student Name',
          onChanged: searchAppointment,
        )
    );
  }

  void searchAppointment(String query) async {
    setState(() {
      if (query == '') {
        appointmentStream =
            appointments.where('instructorId', isEqualTo: firebaseAuth.currentUser!.uid)
                .where('status', isEqualTo: 'Approved')
                .where('dateTime',isLessThan: DateTime.now())
                .orderBy('dateTime', descending: false)
                .snapshots();
      } else {
        appointmentStream =
            appointments.where('instructorId', isEqualTo: firebaseAuth.currentUser!.uid)
                .where('status', isEqualTo: 'Approved')
                .where('dateTime',isLessThan: DateTime.now())
                .orderBy('dateTime',descending: false)
                .orderBy('studentName')
                .startAt([query])
                .endAt(['$query\uf8ff'])
                .snapshots();
      }
    });
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
                stream: appointmentStream,
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
                          onTap: () => displayAppointmentInfo(appointments),
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                          trailing: const Icon(Icons.done_all_outlined,color: Colors.green),
                          leading:
                          Image.asset('images/calendar.png'),
                          subtitle: Text(
                              timeStampToDateTime(appointments['dateTime'])),
                          title: Text(
                              '${appointments['studentName']} ${appointments['studentSurname']}\n'
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

  displayAppointmentInfo(QueryDocumentSnapshot appointment){
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
              Text('Appointment Date : ${date_utils.DateUtils.apiDayFormat(appointment['dateTime'].toDate())}',
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
              Text('Appointment Date : ${date_utils.DateUtils.apiDayFormat(appointment['dateTime'].toDate())}',
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
    }
  }

  timeStampToDateTime(Timestamp timeStamp){
    return '${date_utils.DateUtils.fullDayFormat(timeStamp.toDate())} ${timeStamp.toDate().hour.toString()}.00';
  }
}
