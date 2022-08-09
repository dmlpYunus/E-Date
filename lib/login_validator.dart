import 'package:email_validator/email_validator.dart';

class StudentValidationMixin{

  String? validateMail(String? value){
    if(value == null || value.isEmpty){
      return "E-Mail can't be Empty!";
    }else if(!EmailValidator.validate(value)){
      return "E-Mail format is not valid!";
    }
  }

  String? validatePassword(String? value){
    if(value == null || value.isEmpty){
      return "Password can't be Empty!";
    }else if(value.length<6){
      return "Password name must be at least 6 characters";
    }
  }


  /*String? validateLastName(String? value){
    if(value != null && value.length<2){
      return "Last nNme must be at least 2 characters";
    }
  }
  String? validateGrade(String? value){
    if(value!=null){
      var grade = int.parse(value);
      if(grade <0 || grade > 100){
        return "Must between 0-100";
      }
    }
  }*/
}