abstract class StringValidator {
  bool isValid(String value);
}

class NoneEmptyStringValidator implements StringValidator {
  @override
  bool isValid(String value) {
    return value.isNotEmpty;
  }
}

class EmailAndPasswordValidators {
  final StringValidator emailValidator = NoneEmptyStringValidator();
  final StringValidator passwordValidator = NoneEmptyStringValidator();
  final String invalidEmailErrorText = 'Email can\'t be empty';
  final String invalidPassWordErrorText = 'Password can\'t be empty';
}
