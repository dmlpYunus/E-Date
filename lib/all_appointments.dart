import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterfirebasedeneme/admin_screen.dart';
import 'package:flutterfirebasedeneme/search_widget.dart';
import 'Model/instructor.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/reservation_screen.dart';


class AllAppointments extends StatefulWidget {
  const AllAppointments({Key? key}) : super(key: key);

  @override
  State<AllAppointments> createState() => _AllAppointmentsState();
}

class _AllAppointmentsState extends State<AllAppointments>{
  final textController = TextEditingController();
  AuthService _authService = AuthService();
  CollectionReference appointmentsdb =
  FirebaseFirestore.instance.collection("appointments");
  late Stream<QuerySnapshot<Object?>> appointmentsStream;
  double width = 0;
  double height =0;
  String query = '';

  @override
  void initState() {
    appointmentsStream = appointmentsdb.where('role',isEqualTo: 'student').snapshots();
  }

  buildSearchBar(){
    return Container(
        width: width,
        height: height * 0.1,
        margin: EdgeInsets.only(top : height * 0.12),
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
        appointmentsStream = appointmentsdb.where('role',isEqualTo: 'student').snapshots();
      }else{
        appointmentsStream = appointmentsdb.where('role',isEqualTo: 'student').orderBy('name').startAt([query]).endAt(['$query\uf8ff']).snapshots();
        //instructorsStream = instructorsdb.orderBy("search").where('search',isGreaterThanOrEqualTo: query/*\uf8ff'*/).snapshots();
      }
    });
  }

  buildInstructorsList(){
    return Container(
      height: height*0.5,
      margin: EdgeInsets.only(top : height*0.2),
      child: StreamBuilder(
          stream:appointmentsStream,
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
              children: snapshot.data!.docs.map((instructors) {
                return Center(
                  child: ListTile(
                    onTap: (){
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    trailing: const Text('Student'),
                    leading: Image.asset('images/instructor.png',color: Colors.black,scale: 13),
                    subtitle: Text(instructors['email']),
                    title: Text('${instructors['name']} ${instructors['surname']}',),
                  ),
                );
              }).toList(),
            );
          }),
    );
  }


  @override
  Widget build(BuildContext context){
    height  = MediaQuery.of(context).size.height;
    width  = MediaQuery.of(context).size.width;
    return Scaffold(
      body:Stack(
        children: [
          buildPageTopView(),
          buildInstructorsList(),
          buildSearchBar(),
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



