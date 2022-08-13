import 'package:flutterfirebasedeneme/Model/instructor.dart';

class Appointment{
  late Instructor instructor;
  late DateTime dateTime;
  late String studentID, studentName, studentSurname;

  Appointment();

  Appointment.withValues(this.instructor, this.dateTime, this.studentID, this.studentName,
      this.studentSurname);
}