import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Utils/date_utils.dart' as date_util;
import 'package:flutterfirebasedeneme/Utils/instructor.dart';
import 'package:flutterfirebasedeneme/auth_service.dart';

class ReservationPage extends StatefulWidget {
  late Instructor instructor;
  ReservationPage();
  @override
  State<ReservationPage> createState() => _ReservationPageState();
}



class _ReservationPageState extends State<ReservationPage> {
  AuthService _authService = AuthService();
  List a = ["ADSAD"];
  double height = 0;
  double width = 0;
  List<DateTime> currentMonths = List.empty();
  DateTime currentDateTime = DateTime.now();
  late ScrollController scrollController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentMonths = date_util.DateUtils.daysInMonth(currentDateTime);
    currentMonths.sort((a,b) => a.day.compareTo(b.day));
    currentMonths = currentMonths.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: a.length,
        itemBuilder: ((context, index) => ListTile(
              title: Text(a[index]),
            )),
      ),
    );
  }

  Widget titleView(){
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Text(date_util.DateUtils.months[currentDateTime.month -1] + ' ' + currentDateTime.year.toString(),
      style: const TextStyle(
          color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20),
      ),
    );
  }

  Widget horizantalCapsuleView(){
    return Container(
      width:width,
      height: 150,
      child: ListView.builder(
          itemCount: currentMonths.length,
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context,int index){
            return CapsuleView(index);
          }),
    );
  }

  Widget CapsuleView(int index) {
    return Container();
  }


}
