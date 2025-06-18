
import '../constants/constants.dart';

String? validateNotEmpty(String? input) {
  if (input == null || input.isEmpty) {
    return "This field mustn't be empty";
  }

  return null;
}

String? validatePositiveDouble(String? input) {
  if (input == null || input.isEmpty) {
    return "This field mustn't be empty";
  }

  double? value = double.tryParse(input);
  if (value == null) {
    return "This field must be a positive number";
  }

  if (value <= 0) {
    return "This field must have a positive value";
  }

  return null;
}

String? validatePositiveInt(String? input) {
  if (input == null || input.isEmpty) {
    return "This field mustn't be empty";
  }

  int? value = int.tryParse(input);
  if (value == null) {
    return "This field must be a positive number";
  }

  if (value <= 0) {
    return "This field must have a positive value";
  }

  return null;
}

String? validatePositiveDoubleOrZero(String? input) {
  if (input == null || input.isEmpty) {
    return "This field mustn't be empty";
  }

  double? value = double.tryParse(input);
  if (value == null) {
    return "This field must be a positive number";
  }

  if (value < 0) {
    return "This field must have a positive value";
  }

  return null;
}

String? emailValidator(String? email) {
  if (email == null || email.isEmpty) return "Please enter your E-mail";

  if (!emailRegex.hasMatch(email)) return "E-mail isn't valid";

  return null;
}

String? passwordValidator(String? password) {
  if (password == null || password.isEmpty) return "Please enter your password";

  return null;
}