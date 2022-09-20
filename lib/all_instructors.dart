import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterfirebasedeneme/search_widget.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';

import 'admin_display_appointments.dart';


class AllInstructors extends StatefulWidget {
  const AllInstructors({Key? key}) : super(key: key);

  @override
  State<AllInstructors> createState() => _AllInstructorsState();
}

class _AllInstructorsState extends State<AllInstructors>{
  final textController = TextEditingController();
  AuthService _authService = AuthService();
  CollectionReference instructorsdb =
  FirebaseFirestore.instance.collection("users");
  late Stream<QuerySnapshot<Object?>> instructorsStream;
  double width = 0;
  double height =0;
  String query = '';

  @override
  void initState() {
    super.initState();
    instructorsStream = instructorsdb.where('role',isEqualTo: 'instructor').orderBy("name").snapshots();
  }

  buildSearchBar(){
    return Container(
        width: width,
        height: height * 0.1,
        child: SearchWidget(
          text: query,
          hintText: 'Instructor Name',
          onChanged: searchInstructor,
        )
    );
  }

  void searchInstructor(String query) async{
    setState(()  {
      if(query == ''){
        instructorsStream = instructorsdb.where('role',isEqualTo: 'instructor').orderBy("search").snapshots();
      }else{
        instructorsStream = instructorsdb.where('role',isEqualTo: 'instructor').orderBy("search").startAt([query]).endAt(['$query\uf8ff']).snapshots();
        //instructorsStream = instructorsdb.orderBy("search").where('search',isGreaterThanOrEqualTo: query/*\uf8ff'*/).snapshots();
      }
    });
  }

  buildInstructorsList(){
    return Container(
      height: height*0.8,
      margin: EdgeInsets.only(top : height*0.1),
      child: StreamBuilder(
          stream:instructorsStream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                  child: CircularProgressIndicator()
              );
            }
            return ListView(
              children: snapshot.data!.docs.map((instructors) {
                return Center(
                  child: ListTile(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDisplayAppointment(selected: instructors)));
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    trailing: const Text('Instructor'),
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
      appBar: AppBar(
        backgroundColor:Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text('All Instructors',style: TextStyle(color: Colors.black)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new,color: Colors.black),
        ),
      ),
      body:Stack(
        children: [
          //buildPageTopView(),
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
          SizedBox(width: 25),
          GestureDetector(
            child: const Icon(Icons.arrow_back_ios_new_outlined,size: 30),
            onTap: (){
              Navigator.pop(context);
            },
          ),
          SizedBox(width: width*0.20),
          const Text('All Instructors',
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



