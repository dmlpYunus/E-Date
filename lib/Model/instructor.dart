class Instructor{
  late String id,name,mail,surname,department,fcmToken;

  Instructor();
  Instructor.withValues(this.id, this.name, this.mail, this.surname, this.department);
  Instructor.withFcm(this.id, this.name, this.mail, this.surname, this.department,this.fcmToken);
}