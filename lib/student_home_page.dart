import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterfirebasedeneme/admin_screen.dart';
import 'package:flutterfirebasedeneme/search_widget.dart';
import 'package:flutterfirebasedeneme/student_account_settings.dart';
import 'package:flutterfirebasedeneme/student_past_appointments_screen.dart';
import 'package:flutterfirebasedeneme/student_upcoming_appointments_screen.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Model/instructor.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';
import 'package:flutterfirebasedeneme/reservation_screen.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;

import 'instructor_upcoming_appointments_screen.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final textController = TextEditingController();
  AuthService _authService = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  CollectionReference instructorsdb =
  FirebaseFirestore.instance.collection("users");
  String selectedInst = "1234";
  Instructor selected = Instructor();
  late Stream<QuerySnapshot<Object?>> instructorsStream;
  double width = 0;
  double height = 0;
  late bool isAdmin;
  String query = '';
  String? queryCode = '';


  static const clientId = '1fXKJBccSXadrGQqcjFHtA';  //Client ID
  static const clientSecret = 'uPqRlI90JixAnbmO8CR8JRmroqBlFnqa';   //Client Secret
  static const scopes = [];
  final authorizationEndpoint =
  Uri.parse('https://zoom.us/oauth/authorize');
  final  tokenEndpoint =
  Uri.parse('https://zoom.us/oauth/token');
  final redirectUrl =
  Uri.parse('https://www.google.com/');

  @override
  void initState() {
    super.initState();
    updateFcmToken();
    instructorsStream = instructorsdb.where('role', isEqualTo: 'instructor')
        .orderBy("name")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery
        .of(context)
        .size
        .height;
    width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text('Home Page',style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        )),
        centerTitle: true,
      ),
      drawer: buildDrawer(),
      body: Stack(
        children: [
          //buildHomepageTopView(),
          buildSearchBar(),
          buildInstructorsList(),
          buildAdminPageButton(),
        ],
      ),
    );
  }

  buildHomepageTopView() {
    return Container(
      width: width,
      height: height * 0.2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [
          IconButton(
              icon: const Icon(Icons.person),
            onPressed: (){
                setState(() {
                  buildDrawer();
                  showDialog(context: context, builder: (context) {
                    return Dialog(
                      child: Text('clicked'),
                    );
                  },);
                });
          },
          ),
          const Text('Homepage',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  buildDrawer() {
    return Drawer(
      width: width * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildUserInfo(),
          buildDrawerButtons()
        ],
      ),
    );
  }

  buildDrawerButtons() {
    return Container(
      width: width * 0.75,
      height: height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                  primary: Colors.black,
                  shadowColor: Colors.transparent,
                  fixedSize: Size.fromWidth(width * 0.5),
                  side: const BorderSide(color: Colors.black,width: 1),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const StudentUpcomingAppointments()));
              },
              child: const Text('Upcoming Appointments',style: TextStyle(fontSize: 14.78))),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                  primary: Colors.black,
                  shadowColor: Colors.transparent,
                  fixedSize: Size.fromWidth(width * 0.5),
                  side: const BorderSide(color: Colors.black,width: 1),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const StudentPastAppointments()));
              },
              child: const Text('Past Appointments',style: TextStyle(fontSize: 14.78))),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                  primary: Colors.black,
                  shadowColor: Colors.transparent,
                  fixedSize: Size.fromWidth(width * 0.5),
                  side: const BorderSide(color: Colors.black,width: 1.2),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StudentAccountSettings()));
              },
              child: const Text('Account Settings',style: TextStyle(fontSize: 15.5))),
        ],
      ),
    );
  }

  buildUserInfo()  {
    return Container(
        width: width * 0.75,
        height: height * 0.3,
        margin: EdgeInsets.only(top:height *0.15),
        child: FutureBuilder(
          future: instructorsdb.doc(_firebaseAuth.currentUser!.uid).get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot>snapshot) {
            if(snapshot.hasData){
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                    Image.asset('images/student.png',height: height*0.15,width: width*0.7),
                    Text('${snapshot.data!.get('name')} ${snapshot.data!.get('surname')}'),
                    Text('${snapshot.data!.get('email')}'),
                    Text(capitalizeFirstLetter(snapshot.data!.get('role')))]
              );
            }else if(snapshot.hasError){
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [Text(snapshot.error.toString()),
                    Text('${snapshot.data!.get('email')}')]);
            } else{
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  const [Text('EMPTY')]);
            }
          },
        )
    );
  }

  buildSearchBar() {
    return Container(
        width: width,
        height: height * 0.1,
        //margin: EdgeInsets.only(top: height * 0.12),
        child: SearchWidget(
          text: query,
          hintText: 'Instructor Name',
          onChanged: searchInstructor,
        )
    );
  }

  buildInstructorsList() {
    return Container(
      height: height * 0.7,
      margin: EdgeInsets.only(top: height * 0.1),
      child: StreamBuilder(
          stream: instructorsStream,
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
                    onTap: () {
                      selected = buildInstructor(instructors);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                              ReservationPage(
                                  title: selectedInst, instructor: selected)));
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    trailing: const Text('Instructor'),
                    leading: Image.asset(
                        'images/instructor.png', color: Colors.black,
                        scale: 13),
                    subtitle: Text(instructors['email']),
                    title: Text(
                      '${instructors['name']} ${instructors['surname']}',),
                  ),
                );
              }).toList(),
            );
          }),
    );
  }

  buildAdminPageButton() {
    return Container(
      width: width,
      height: height * 0.2,
      margin: EdgeInsets.only(top: height * 0.7),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.black,
                shadowColor: Colors.transparent,
                fixedSize: Size.fromWidth(width * 0.5),
                side: const BorderSide(color: Colors.black,width: 1),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const adminScreen(),));
            },
            child: const Text('Admin Page'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.black,
                shadowColor: Colors.transparent,
                fixedSize: Size.fromWidth(width * 0.5),
                side: const BorderSide(color: Colors.black,width: 1),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
            onPressed: () {
              httpOnTap();
            },
            child: const Text('HTTP'),
          ),
        ],
      ),
    );
  }

  void httpOnTap() async {

    var client = await createClient();
    print(await client.credentials.accessToken);
    print(await client.read(Uri.parse('https://api.zoom.us/v2/users/me/meetings')));

    //await client.post(Uri.parse('https://zoom.us/oauth/token'));
    // Once you have a Client, you can use it just like any other HTTP client.
    //print(await client.head(authorizationEndpoint));
    //print(await client.read(Uri.parse('http://example.com/protected-resources.txt')));



    //await credentialsFile.writeAsString(client.credentials.toJson());
  }



  Future<oauth2.Client> createClient () async{
    //const clientId = '1fXKJBccSXadrGQqcjFHtA';  //Client ID
    const clientId = 'HGI6qXptRICTxqQ9G5ynAw';  //Client ID
    //const clientSecret = 'uPqRlI90JixAnbmO8CR8JRmroqBlFnqa';   //Client Secret
    const clientSecret = 'G1z4aoYbTZy7pYwbWQzR9eitLj2nFAxW';   //Client Secret
    const scopes = [];
    final authorizationEndpoint =
    Uri.parse('https://zoom.us/oauth/authorize');
    final tokenEndpoint =
    Uri.parse('https://zoom.us/oauth/token');
    /*final redirectUrl =
    Uri.parse('https://www.google.com/');*/
    final redirectUrl =
    Uri.parse('https://flutterdenemee.page.link/y1E4');


    var grant = oauth2.AuthorizationCodeGrant(
        clientId, authorizationEndpoint, tokenEndpoint,
        secret: clientSecret,basicAuth: false);

    var authorizationUrl = grant.getAuthorizationUrl(redirectUrl);

    await launchUrl(authorizationUrl,mode: LaunchMode.externalNonBrowserApplication);


    var responseUrl = /*await uriLinkStream.firstWhere((element) =>
        element.toString().
        startsWith(redirectUrl.toString()));*/
    await listen(redirectUrl);


    if(responseUrl == null){
      throw Exception('Response URL was Null.');
    }

    queryCode = responseUrl.queryParameters['code'];
    return await grant.handleAuthorizationResponse(responseUrl.queryParameters);
  }

  Future<void> redirect (Uri authorizationUrl) async {
    if(await canLaunchUrl(authorizationUrl)){
      await launchUrl(authorizationUrl);
    }else{
      throw Exception('Unable to launch authorization URL');
    }
  }


  Future<Uri?> listen(Uri redirectUrl) async {
    return await uriLinkStream.firstWhere((element) =>
        element.toString().
        startsWith(redirectUrl.toString()));
  }

  getToken() async {

  }






  createJson() {
    var json =
    {"agenda": "Appointment",
      "default_password": false,
      "duration": 60,
      "password": "123456",
      "pre_schedule": false,
      "recurrence": {
        "end_date_time": "2022-04-02T15:59:00Z",
        "end_times": 7,
        "monthly_day": 1,
        "monthly_week": 1,
        "monthly_week_day": 1,
        "repeat_interval": 1,
        "type": 1,
        "weekly_days": "1"
      },
      "schedule_for": "yunus.dmlp@gmail.com",
      "settings": {
        "additional_data_center_regions": [
          "TY"
        ],
        "allow_multiple_devices": true,
        "alternative_hosts": "jchill@example.com;thill@example.com",
        "alternative_hosts_email_notification": true,
        "approval_type": 2,
        "approved_or_denied_countries_or_regions": {
          "approved_list": [
            "CX"
          ],
          "denied_list": [
            "CA"
          ],
          "enable": true,
          "method": "approve"
        },
        "audio": "telephony",
        "authentication_domains": "example.com",
        "authentication_exception": [
          {
            "email": "jchill@example.com",
            "name": "Jill Chill"
          }
        ],
        "authentication_option": "signIn_D8cJuqWVQ623CI4Q8yQK0Q",
        "auto_recording": "cloud",
        "breakout_room": {
          "enable": true,
          "rooms": [
            {
              "name": "room1",
              "participants": [
                "jchill@example.com"
              ]
            }
          ]
        },
        "calendar_type": 1,
        "close_registration": false,
        "contact_email": "jchill@example.com",
        "contact_name": "Jill Chill",
        "email_notification": true,
        "encryption_type": "enhanced_encryption",
        "focus_mode": true,
        "global_dial_in_countries": [
          "US"
        ],
        "host_video": true,
        "jbh_time": 0,
        "join_before_host": false,
        "language_interpretation": {
          "enable": true,
          "interpreters": [
            {
              "email": "interpreter@example.com",
              "languages": "US,FR"
            }
          ]
        },
        "meeting_authentication": true,
        "meeting_invitees": [
          {
            "email": "jchill@example.com"
          }
        ],
        "mute_upon_entry": false,
        "participant_video": false,
        "private_meeting": false,
        "registrants_confirmation_email": true,
        "registrants_email_notification": true,
        "registration_type": 1,
        "show_share_button": true,
        "use_pmi": false,
        "waiting_room": false,
        "watermark": false,
        "host_save_video_order": true,
        "alternative_host_update_polls": true
      },
      "start_time": "2022-03-25T07:32:55Z",
      "template_id": "Dv4YdINdTk+Z5RToadh5ug==",
      "timezone": "America/Los_Angeles",
      "topic": "My Meeting",
      "tracking_fields": [
        {
          "field": "field1",
          "value": "value1"
        }
      ],
      "type": 2
    };
    return json;
  }



  void searchInstructor(String query) async {
    setState(() {
      if (query == '') {
        instructorsStream =
            instructorsdb.where('role', isEqualTo: 'instructor').orderBy(
                "search").snapshots();
      } else {
        instructorsStream =
            instructorsdb.where('role', isEqualTo: 'instructor').orderBy(
                "search").startAt([query]).endAt(['$query\uf8ff']).snapshots();
      }
    });
  }

  Instructor buildInstructor(QueryDocumentSnapshot inst) {
   Map<String,dynamic> instMap = inst.data() as Map<String,dynamic>;
   if(instMap.containsKey('fcmToken')){
     print('WİTH FCM');
     return Instructor.withFcm(inst['UID'],
         inst['name'],
         inst['email'],
         inst['surname'], "Computer", inst['fcmToken']);
   }else{
     print('NOT FCM');
     return Instructor.withValues(
         inst['UID'], inst['name'], inst['email'], inst['surname'],
         "Computer");
   }
  }

  void updateFcmToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      //var a = {'fcmToken': value};
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({'fcmToken' : value});
      print('FCM TOKEN UPDATED');
    });
  }

  String capitalizeFirstLetter(String s){
    String capitalizedString = s.characters.first.toUpperCase()+ s.substring(1)  ;
    return capitalizedString;
  }
}

