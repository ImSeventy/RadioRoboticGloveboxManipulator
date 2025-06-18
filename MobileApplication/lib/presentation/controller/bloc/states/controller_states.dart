class ControllerState {}

class ControllerInitialState extends ControllerState{}

class ControllerLoadingState extends ControllerState {}

class ControllerSuccessState extends ControllerState {}

class ControllerErrorState extends ControllerState {
  final String message;

  ControllerErrorState(this.message);
}

class ControllerSaveStepLoadingState extends ControllerLoadingState{}

class ControllerSaveStepSuccessState extends ControllerSuccessState {}

class ControllerSaveProcessLoadingState extends ControllerLoadingState {}

class ControllerSaveProcessSuccessState extends ControllerSuccessState {}

class ControllerSaveProcessErrorState extends ControllerErrorState {
  ControllerSaveProcessErrorState(super.message);
}

class GetProcessesLoadingState extends ControllerLoadingState {}

class GetProcessesSuccessState extends ControllerSuccessState {}

class GetProcessesErrorState extends ControllerErrorState {
  GetProcessesErrorState(super.message);

}

class DeleteProcessLoadingState extends ControllerLoadingState {}

class DeleteProcessSuccessState extends ControllerSuccessState {}

class DeleteProcessErrorState extends ControllerErrorState {
  DeleteProcessErrorState(super.message);
}