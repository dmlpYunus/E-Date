import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterfirebasedeneme/search_widget.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'utils/date_utils.dart' as date_util;


class AllAppointments extends StatefulWidget {
  const AllAppointments({Key? key}) : super(key: key);

  @override
  State<AllAppointments> createState() => _AllAppointmentsState();
}

class _AllAppointmentsState extends State<AllAppointments>{
  final textController = TextEditingController();
  final AuthService _authService = AuthService();
  CollectionReference appointmentsdb =
  FirebaseFirestore.instance.collection("appointments");
  late Stream<QuerySnapshot<Object?>> appointmentsStream;
  String status = 'pending';
  double width = 0;
  double height =0;
  String query = '';

  @override
  void initState() {
    appointmentsStream = appointmentsdb.orderBy('dateTime').snapshots();
  }

  buildStatusButtons(){
    return Container(
      width: width,
      height: height * 0.1,
      margin: EdgeInsets.only(top : height * 0.12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ElevatedButton(
            onPressed: (){
              setState(() {
                status = 'denied';
                appointmentsStream = appointmentsdb.where('status',isEqualTo: status).orderBy('dateTime',descending: false).snapshots();
              });
            },
            style: ButtonStyle(side: MaterialStateBorderSide.resolveWith((states) => const BorderSide(color: Colors.black,style: BorderStyle.solid)),
            backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
            shadowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
            ),
            child: const Text('Denied',style: TextStyle(color: Colors.black),)),
          ElevatedButton(
              onPressed: (){
                setState(() {
                  status = 'pending';
                  appointmentsStream = appointmentsdb.where('status',isEqualTo: status).orderBy('dateTime',descending: false).snapshots();
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
                  status = 'accepted';
                  appointmentsStream = appointmentsdb.where('status',isEqualTo: status).orderBy('dateTime',descending: false).snapshots();
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

  buildSearchBar(){
    return Container(
        width: width,
        height: height * 0.1,
        margin: EdgeInsets.only(top : height * 0.2),
        child: SearchWidget(
          text: query,
          hintText: 'Appointment',
          onChanged: searchAppointment,
        )
    );
  }

  void searchAppointment(String query) async{
    setState(()  {
      if(query == ''){
        if(status !=''){
          appointmentsStream = appointmentsdb.where('status',isEqualTo: status).orderBy('dateTime',descending: false).snapshots();
        }else{
          appointmentsStream = appointmentsdb.orderBy('dateTime',descending: false).snapshots();
        }
      }else{
        if(status !=''){
          appointmentsStream = appointmentsdb.where('status',isEqualTo: status)
              .orderBy('dateTime',descending: false).snapshots();
        }else{
          appointmentsStream = appointmentsdb.orderBy('dateTime',descending: false).snapshots();
        }
      }
    });
  }

  buildInstructorsList() {
    return Container(
      height: height*0.5,
      margin: EdgeInsets.only(top : height*0.25),
      child: StreamBuilder(
          stream: appointmentsStream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              //return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData) {
              return const Center(
                  child: Text('Appointments Not Found')
              );
            }
            return ListView(
              children: snapshot.data!.docs.map((appointments) {
                return Center(
                  child: ListTile(
                    onTap: (){
                      appointmentOnTap(appointments);
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    leading: Image.asset('images/calendar.png'),
                    trailing: (appointments['status'] == 'pending') ?
                    const Icon(Icons.pending_rounded) :
                    (appointments['status'] == 'denied') ?
                    const Icon(Icons.cancel_rounded) :
                    const Icon(Icons.done_outlined),
                    subtitle: Text(date_util.DateUtils.apiDayFormat(appointments['dateTime'].toDate())),
                    title: Text('${appointments['studentName']} ${appointments['studentSurname']}',),
                  ),
                );
              }).toList(),
            );
          }),
    );
  }

  appointmentOnTap(QueryDocumentSnapshot appointment){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Container(
              height: height*0.5,
              width: 320,
              padding: const EdgeInsets.only(right: 12,left: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('Appointment Details',style: TextStyle(fontSize: 24)),
                  const SizedBox(
                    height: 10,
                  ),
                   Text(
                    "Appointment ID : ${appointment.id}",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                   Text('Appointment Date : ${date_util.DateUtils.apiDayFormat(appointment['dateTime'].toDate())}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text('Instructor ID : ${appointment['instructorId']}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text('Instructor : ${appointment['instructorName']} ${appointment['instructorSurname']}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text('Student ID : ${appointment['studentId']}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text('Student : ${appointment['studentName']} ${appointment['studentSurname']}',
                    style: const TextStyle(color: Colors.black),
                  ),Text('Student UID : ${appointment['studentUID']}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    width: 320,
                    child: Row(
                      children : [
                        ElevatedButton(
                        onPressed: () {
                          setState(() {
                            appointmentsdb.doc(appointment.id).update({'status' : 'cancelled'});
                            Navigator.pop(context);
                          });
                        },
                          style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                              shadowColor :MaterialStateColor.resolveWith((states) => Colors.transparent) ),
                        child: const Text("Cancel",style: TextStyle(color: Colors.red)),

                      ),
                        OutlinedButton(
                          onPressed: (){},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(width: 3,color: Colors.transparent),
                            shadowColor: Colors.transparent,
                            backgroundColor: Colors.transparent
                          ),
                          child: const Text("Ok"),

                        ),]
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }


  @override
  Widget build(BuildContext context){
    height  = MediaQuery.of(context).size.height;
    width  = MediaQuery.of(context).size.width;
    return Scaffold(
      body:Stack(
        children: [
          buildPageTopView(),
          buildStatusButtons(),
          buildSearchBar(),
          buildInstructorsList(),
        ],
      ) ,
    );
  }

  buildPageTopView(){
    return Container(
      width: width,
      height: height * 0.2,
      child: Row(
        children: [
          const SizedBox(width: 25),
          GestureDetector(
            child: const Icon(Icons.arrow_back_ios_new_outlined,size: 30),
            onTap: (){
              Navigator.pop(context);
            },
          ),
          SizedBox(width: width*0.15),
          const Text('All Appointments',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }
}



