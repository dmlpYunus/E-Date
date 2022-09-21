import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebasedeneme/admin_display_appointments.dart';
import 'package:flutterfirebasedeneme/search_widget.dart';



class AllStudents extends StatefulWidget {
  const AllStudents({Key? key}) : super(key: key);

  @override
  State<AllStudents> createState() => _AllStudentsState();
}

class _AllStudentsState extends State<AllStudents>{
  final textController = TextEditingController();
  CollectionReference studentsdb =
  FirebaseFirestore.instance.collection("users");
  late Stream<QuerySnapshot<Object?>> studentsStream;
  double width = 0;
  double height =0;
  String query = '';

  @override
  void initState() {
    studentsStream = studentsdb.where('role',isEqualTo: 'student').snapshots();
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
        title: Text('All Students',style: TextStyle(color: Colors.black)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new,color: Colors.black),
        ),
      ),
      body:Stack(
        children: [
          buildInstructorsList(),
          buildSearchBar(),
        ],
      ) ,
    );
  }

  buildSearchBar(){
    return Container(
        width: width,
        height: height * 0.1,
        child: SearchWidget(
          text: query,
          hintText: 'Student Name',
          onChanged: searchStudent,
        )
    );
  }

  void searchStudent(String query) async{
    setState(()  {
      if(query == ''){
        studentsStream = studentsdb.where('role',isEqualTo: 'student').snapshots();
      }else{
        studentsStream = studentsdb.where('role',isEqualTo: 'student').orderBy('search').startAt([query]).endAt(['$query\uf8ff']).snapshots();
        //instructorsStream = instructorsdb.orderBy("search").where('search',isGreaterThanOrEqualTo: query/*\uf8ff'*/).snapshots();
      }
    });
  }

  buildInstructorsList(){
    return Container(
      height: height*0.8,
      margin: EdgeInsets.only(top : height*0.1),
      child: StreamBuilder(
          stream:studentsStream,
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
              children: snapshot.data!.docs.map((students) {
                return Center(
                  child: ListTile(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDisplayAppointment(selected: students)));
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    trailing: const Text('Student'),
                    leading: Image.asset('images/student.png',color: Colors.black,scale: 13),
                    subtitle: Text(students['email']),
                    title: Text('${students['name']} ${students['surname']}',),
                  ),
                );
              }).toList(),
            );
          }),
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
          const Text('All Students',
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



