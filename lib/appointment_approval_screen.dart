import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'utils/date_utils.dart' as date_utils;

class AppointmentApproval extends StatefulWidget {
  const AppointmentApproval({Key? key}) : super(key: key);
  @override
  State<AppointmentApproval> createState() => _AppointmentApprovalState();
}

class _AppointmentApprovalState extends State<AppointmentApproval> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
        title: const Text('Pending Appointment Requests'),
      ),
      body: Stack(
        children: [buildPendingAppointmentsList(),buildApprovalInfo()],
      ),
    );
  }

  buildApprovalInfo(){
    return Container(
      width: width,
      height: height * 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('WELCOME',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green)),
          Text('Please Swipe to Approve or Deny'),
        ],
      ),
    );
  }

  buildPendingAppointmentsList() {
    return Container(
      margin: EdgeInsets.only(top: height * 0.1),
      width: width,
      height: height * 0.9,
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: appointments
                    .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
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
                        child: Slidable(
                          key: Key(appointments.id),
                          startActionPane: slideForApprove(appointments),
                          endActionPane: slideForDeny(appointments),
                          closeOnScroll: true,
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

  slideForApprove(QueryDocumentSnapshot appointment) {
    return ActionPane(
      motion: const ScrollMotion(),
      dismissible: DismissiblePane(onDismissed: () {
        approveAppointment(appointment);
      }),
      children: [
        SlidableAction(
          onPressed: (context) {
            approveAppointment(appointment);
          },
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          icon: Icons.task_alt_outlined,
          label: 'Approve',
        ),
      ],
    );
  }

  approveAppointment(QueryDocumentSnapshot appointment) {
    appointments.doc(appointment.id).update({'status': 'Approved'});
    displaySnackBar('Appointment Approved');

  }

  denyAppointment(QueryDocumentSnapshot appointment) async {

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Container(
              height: 200,
              width: 320,
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Deny Reason",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const TextField(
                    style: TextStyle(color: Colors.white),
                    autofocus: true,
                    decoration: InputDecoration(
                        hintText: 'Specify the reason for the refusal',
                        hintStyle: TextStyle(color: Colors.white60)),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 320,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          appointments.doc(appointment.id).update({'status': 'Denied'});
                          appointments.doc(appointment.id).update({'reason': 'Denied'});
                          displaySnackBar('Appointment Denied');
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text("Submit"),
                    ),
                  )
                ],
              ),
            ),
          );
        });


  }

  slideForDeny(QueryDocumentSnapshot appointment) {
    return ActionPane(
      motion: const ScrollMotion(),
      dismissible: DismissiblePane(onDismissed: () {
        denyAppointment(appointment);
      }),
      children: [
        SlidableAction(
          onPressed: (context) {
            denyAppointment(appointment);
          },
          backgroundColor: const Color(0xFFFE4A49),
          foregroundColor: Colors.white,
          icon: Icons.cancel_rounded,
          label: 'Deny',
        ),
      ],
    );
  }

  timeStampToDateTime(Timestamp timeStamp) {
    return '${date_utils.DateUtils.fullDayFormat(timeStamp.toDate())} ${timeStamp.toDate().hour.toString()}.00';
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
      backgroundColor: Colors.green,
      duration: const Duration(milliseconds: 600),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


}
