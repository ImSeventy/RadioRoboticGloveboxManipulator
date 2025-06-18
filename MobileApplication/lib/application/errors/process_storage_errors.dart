import 'package:rrgbm/application/errors/BaseError.dart';

class ProcessStorageErrorMessages {
  static const String savingProcessError = "Error occurred while saving process";
  static const String fetchingProcessesError = "Error occurred while fetching processes";
  static const String deletingProcessError = "Error occurred while deleting process";
}

class SavingProcessError extends BaseError {
  SavingProcessError() : super(ProcessStorageErrorMessages.savingProcessError);

}

class FetchingProcessesError extends BaseError {
  FetchingProcessesError() : super(ProcessStorageErrorMessages.fetchingProcessesError);

}

class DeletingProcessError extends BaseError {
  DeletingProcessError() : super(ProcessStorageErrorMessages.deletingProcessError);
}