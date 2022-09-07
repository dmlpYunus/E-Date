import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterfirebasedeneme/admin_screen.dart';
import 'package:flutterfirebasedeneme/search_widget.dart';
import 'package:flutterfirebasedeneme/student_account_settings.dart';
import 'Model/instructor.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/login_screen.dart';
import 'package:flutterfirebasedeneme/reservation_screen.dart';
import 'package:flutterfirebasedeneme/signup_screen.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  final textController = TextEditingController();
  AuthService _authService = AuthService();
  CollectionReference instructorsdb =
  FirebaseFirestore.instance.collection("instructors");
  String selectedInst = "1234";
  Instructor selected = Instructor();
  late Stream<QuerySnapshot<Object?>> instructorsStream;
  double width = 0;
  double height =0;
  late bool isAdmin;
  String query = '';

  @override
  void initState() {
    instructorsStream = instructorsdb.orderBy("name").snapshots();
  }

  buildSearchBar(){
    return Container(
      width: width,
      height: height * 0.1,
      margin: EdgeInsets.only(top : height * 0.12),
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
        instructorsStream = instructorsdb.orderBy("search").snapshots();
      }else{
      //instructorsStream = instructorsdb.orderBy("search").where('search',isGreaterThanOrEqualTo: query/*\uf8ff'*/).snapshots();
      instructorsStream = instructorsdb.orderBy("search").startAt([query]).endAt(['$query\uf8ff']).snapshots();
      }
    });
  }

  buildInstructorsList(){
    return Container(
      height: height*0.5,
      margin: EdgeInsets.only(top : height*0.2),
      child: StreamBuilder(
          stream:instructorsStream, //instructorsdb.orderBy("name").snapshots(),
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
                      selected = buildInstructor(instructors);
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> ReservationPage(
                          title: selectedInst,instructor: selected)));
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    trailing: const Text('Instructor'),//const Icon(Icons.access_alarm_rounded),
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

  buildAdminPageButton(){
    return Container(
      width: width,
      height: height*0.15,
      margin: EdgeInsets.only(top: height * 0.8),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const adminScreen(),));
            },
            child: const Text('Admin Page'),

          ),
          ElevatedButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentAccountSettings(),));
            },
            child: const Text('Account Settings'),

          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    height  = MediaQuery.of(context).size.height;
    width  = MediaQuery.of(context).size.width;
    return Scaffold(
      body:Stack(
        children: [
          buildHomepageTopView(),
          buildInstructorsList(),
          buildSearchBar(),
          buildAdminPageButton(),
        ],
      ) ,
    );
    /*return Scaffold(
      body:Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: instructorsdb.orderBy("name").snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text("Loading..."),
                          );
                        }
                        return ListView(
                          children: snapshot.data!.docs.map((instructors) {
                            return Center(
                              child: ListTile(
                                onTap: (){
                                  selected = buildInstructor(instructors);
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> ReservationPage(
                                        title: selectedInst,instructor: selected)));
                                },
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                                trailing: const Icon(Icons.access_alarm_rounded),
                                leading: const Icon(Icons.insert_invitation_rounded),
                                subtitle: Text(instructors['email']),
                                title: Text('${instructors['name']} ${instructors['surname']}'),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                ),
                ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const adminScreen()));
                },
                    child: const Text("Admin Screen")),
                Text("Selected instructor : $selectedInst"),
                Row(
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 2,
                      child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueAccent)),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const LoginPage()));
                        },
                        child: const Text("Login"),
                      ),
                    ),
                    Flexible(
                        fit: FlexFit.tight,
                        flex: 2,
                        child: RaisedButton(
                          color: Colors.redAccent,
                          onPressed: () {

                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => const SignupPage()));
                          },
                          child: const Text("Sign-Up"),
                        )),Flexible(
                        fit: FlexFit.tight,
                        flex: 4,
                        child: RaisedButton(
                          color: Colors.orangeAccent,
                          onPressed: () {
                            _authService.logOut();
                          },
                          child: const Text("Log-Out"),
                        ))
                  ],
                ),
              ],
            )
    );             */
  }

  buildHomepageTopView(){
    return Container(
      width: width,
      height: height * 0.2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
             Text('Homepage',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                )),
        ],
      ),
    );
  }

  Instructor buildInstructor(QueryDocumentSnapshot inst){
    //if(inst[''] == null){
      return Instructor.withValues(inst['id'], inst['name'], inst['email'], inst['surname'], "Computer");
    /*}else{
      return Instructor.withFcm(inst['id'],
          inst['name'],
          inst['email'],
          inst['surname'],"Computer",inst['fcmToken']);*/
    }
  }

  /*class MySearchDelegate extends SearchDelegate{
    @override
  List<Widget> buildActions(BuildContext context) {
    return [
    IconButton(
      icon: Icon(Icons.arrow_back_ios_new_outlined),
      onPressed: (){
        close(context, null);
      },
    )
    ];
  }
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_new_outlined),
      onPressed: (){
        if(query.isEmpty){
          close(context, null);
        }
        else{
          query = '';
        }
      },
    );
  }
  @override
  Widget buildResults(BuildContext context) {

  }

    @override
  Widget buildSuggestions(BuildContext context) {

  }
}*/

