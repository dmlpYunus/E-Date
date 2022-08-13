import 'package:email_validator/email_validator.dart';

class AccountValidationMixin{

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

  String? validateName(String? value){
    if(value == null || value.isEmpty){
      return "Name can't be Empty!";
    }
  }

  String? validateSurname(String? value){
    if(value == null || value.isEmpty){
      return "Surname can't be Empty!";
    }
  }

}