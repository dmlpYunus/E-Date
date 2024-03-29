import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterfirebasedeneme/login_validator.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utils/date_utils.dart' as date_utils;
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'auth_service.dart';

class AppointmentApproval extends StatefulWidget {
  const AppointmentApproval({Key? key}) : super(key: key);
  @override
  State<AppointmentApproval> createState() => _AppointmentApprovalState();
}

class _AppointmentApprovalState extends State<AppointmentApproval> with AccountValidationMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  AuthService authService = AuthService();
  late Map<String, dynamic> currentUser;
  double width = 0.0;
  double height = 0.0;
  String? queryCode = '';
  CollectionReference appointments =
      FirebaseFirestore.instance.collection("appointments");
  late Stream<QuerySnapshot<Object?>> app;
  var key = GlobalKey<FormState>();
  final denyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded),onPressed: () =>Navigator.pop(context)),
        title: const Text('Pending Appointment Requests',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600)),
      ),
      body: Stack(
        children: [buildPendingAppointmentsList(),buildApprovalInfo()],
      ),
    );
  }

  @override
  void initState()  {
    currentUserMap();
    app = appointments
        .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
        .where('status',isEqualTo: 'pending')
        .orderBy('dateTime', descending: false)
        .snapshots();
  }



  buildApprovalInfo(){
    return Container(
      width: width,
      height: height * 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('WELCOME',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueAccent,fontSize: 24)),
          Text('Please Swipe to Approve or Deny',style: TextStyle(fontSize: 18)),
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
                    .where('status',isEqualTo: 'pending')
                    .where('instructorId',isEqualTo: _firebaseAuth.currentUser!.uid)
                    .orderBy('dateTime', descending: false)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator());
                  }else if (!snapshot.hasData) {
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
                            onTap: () => displayAppointmentInfo(appointments),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 15),
                            trailing: Text('${appointments['dateTime'].toDate().hour}:00',style: TextStyle(color: Colors.deepOrange,fontSize: 20)),
                            leading:
                                Image.asset('images/calendarr.png'),
                            subtitle: Text(
                                timeStampToDateTime(appointments['dateTime'])),
                            title: Text(
                                '${appointments['studentName']} ${appointments['studentSurname']} \n'
                                '${appointments['studentId']}',style: TextStyle(fontWeight: FontWeight.w600,overflow: TextOverflow.ellipsis)),
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
  
  pendingDialog(QueryDocumentSnapshot appointment){
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: height*0.5,
        width: 450,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.04),
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
            SizedBox(
              height: height * 0.02,
            ),
            SizedBox(
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
                      )]
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  displayAppointmentInfo(QueryDocumentSnapshot appointment){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return pendingDialog(appointment);
        });
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

  approveAppointment(QueryDocumentSnapshot appointment) async {
    var client = await createClient();
    var response = await client.post(Uri.parse('https://api.zoom.us/v2/users/me/meetings'),headers: createMeetingPostHeader(),body: createMeetingPostBody(appointment));
    var zoomLink = await jsonDecode(await response.body)['join_url'];
    if(await zoomLink != null ||zoomLink != ''){
      await appointments.doc(appointment.id).update({'status': 'Approved','zoomLink' : zoomLink});
      await _firestore.collection('users').doc(appointment['studentUID']).get().then((student) {
        displaySnackBar('Appointment Approved');
        sendNotification(student.get('fcmToken'),'${currentUser['name']} ${currentUser['surname']}');
      }
      );
    }else{
      displaySnackBar('Something Went Wrong');
    }
  }

  getSelectedUser(String uID) async {
    DocumentSnapshot documentSnapshot =  await _firestore.collection('users').doc(uID).get();
    return documentSnapshot.data();
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
              height: height * 0.3,
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
                  Form(
                    key: key,
                    child:  TextFormField(
                      style: TextStyle(color: Colors.white),
                      autofocus: true,
                      validator: validateDenyReason,
                      controller: denyController,
                      decoration: InputDecoration(
                          hintText: 'Specify the reason for the refusal',
                          hintStyle: TextStyle(color: Colors.white60)),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 320,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() async {
                          if(key.currentState!.validate()){
                            key.currentState!.save();
                              appointments.doc(appointment.id).update({'status': 'Denied'});
                              appointments.doc(appointment.id).update({'reason': denyController.text});
                              displaySnackBar('Appointment Denied');
                              Navigator.of(context).pop();
                          }
                        });

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

  void sendNotification(String token,String instructorName) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
          'key=AAAAg6ILid8:APA91bEV1G0iHc580oX91li0Co1qwPiZmOmjCLHMaul4Xa64uPN8IK19XgwLmtruHpk8X8EDGUwSxgnVITWgNwipRBlPuK9JJDJhcUn8YOZoEidHNlhlfhZNLZNqCYZ1QP7d0i2gKSfU'
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'title': 'Appointment Request Accepted',
              'body': '$instructorName Accepted Your Appointment Request'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': token,
          },
        ),
      );
    } catch (e) {
      displaySnackBar(e.toString());
    }
  }

  Future<oauth2.Client> createClient () async{
    const clientId = 'HGI6qXptRICTxqQ9G5ynAw';  //Client ID
    const clientSecret = 'G1z4aoYbTZy7pYwbWQzR9eitLj2nFAxW';   //Client Secret
    //const scopes = [];
    final authorizationEndpoint =
    Uri.parse('https://zoom.us/oauth/authorize');
    final tokenEndpoint =
    Uri.parse('https://zoom.us/oauth/token');
    final redirectUrl =
    Uri.parse('https://flutterdenemee.page.link/y1E4');


    var grant = oauth2.AuthorizationCodeGrant(
        clientId, authorizationEndpoint, tokenEndpoint,
        secret: clientSecret,basicAuth: false);

    var authorizationUrl = grant.getAuthorizationUrl(redirectUrl);

    await launchUrl(authorizationUrl,mode: LaunchMode.externalNonBrowserApplication);


    var responseUrl = await uriLinkStream.firstWhere((element) =>
        element.toString().
        startsWith(redirectUrl.toString()));
    //await listen(redirectUrl);


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

  createMeetingPostHeader(){
    return <String, String>{
      'Content-Type': 'application/json',
      'Authorization':
      'Bearer eyJhbGciOiJIUzUxMiIsInYiOiIyLjAiLCJraWQiOiJmMDhmZjBmOC01NjE2LTQ2YjctOTY4Yi03NDM5YjAxNDRhY2MifQ.eyJ2ZXIiOjcsImF1aWQiOiJkNmViZmU4NWI0NzM2Y2M4ZWM0NjJmOTJiMmI3MjE1NiIsImNvZGUiOiJibTVIS3pXVmpIXzBaRkw2SHF1UmFhRU82NEMtcTlOWUEiLCJpc3MiOiJ6bTpjaWQ6SEdJNnFYcHRSSUNUeHFROUc1eW5BdyIsImdubyI6MCwidHlwZSI6MCwidGlkIjowLCJhdWQiOiJodHRwczovL29hdXRoLnpvb20udXMiLCJ1aWQiOiIwWkZMNkhxdVJhYUVPNjRDLXE5TllBIiwibmJmIjoxNjYzNDQ2NTczLCJleHAiOjE2NjM0NTAxNzMsImlhdCI6MTY2MzQ0NjU3MywiYWlkIjoiNTVieDQyNjlTRHlzaHJ6WGZUd3RXQSIsImp0aSI6IjNjZTYzYjljLTc3MmItNDBlNi05YWM3LWEzOWJiZjAyY2E3YyJ9.LKlS26vfuNDdwn8YoGFsc8agBEuVIT-uGNr4NLJNkdWbUWmR9zlm_6ezguVri7igZRE5YWq-fNWNQL9pMdRw4A'
    };
  }

  createMeetingPostBody(QueryDocumentSnapshot appointment){
    return jsonEncode(
        <String,dynamic>{
          "topic": "${appointment['studentName']} - ${appointment['instructorName']} Appointment",
          "type": 2,
          "start_time": "${appointment['dateTime'].toDate().year.toString()}-${appointment['dateTime'].toDate().month.toString()}-${appointment['dateTime'].toDate().day.toString()}T${appointment['dateTime'].toDate().hour.toString()}: 00: 00",
          "duration": "60",
          "timezone": "Europe/Istanbul",
          "agenda": "Isık University Instructor Appointment",
          //"schedule_for": appointment['studentMail'],
          "recurrence": <String,dynamic> {"type": 1,
            "repeat_interval": 1
          },
          "settings":<String,dynamic> {"host_video": "true",
            "participant_video": "true",
            "join_before_host": "true",
            "mute_upon_entry": "False",
            "watermark": "true",
            "audio": "voip",
            "auto_recording": "cloud",
            "meeting_invitees": [
              <String,dynamic> {
                "email": appointment['studentMail']
              }
            ]
          }
        }
    );
  }

  currentUserMap(){
    authService.getCurrentUser()!.then((value){
      currentUser =value as Map<String,dynamic>;
    });
  }
}
