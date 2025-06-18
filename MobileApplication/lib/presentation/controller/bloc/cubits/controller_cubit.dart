import 'package:bloc/bloc.dart';
import 'package:rrgbm/application/services/process_storage/IProcessStorageService.dart';
import 'package:rrgbm/presentation/controller/bloc/states/controller_states.dart';
import 'package:rrgbm/presentation/shared/constants/joints_data.dart';

import '../../../../domain/models/AutomationProcess.dart';

class ControllerCubit extends Cubit<ControllerState> {
  List<List<String>> steps = [];
  List<AutomationProcess> processes = [];
  final Map<String, int> currentReadings = {};
  final IProcessStorageService processStorageService;

  ControllerCubit({required this.processStorageService})
      : super(ControllerInitialState()) {
    for (var jointData in jointsData) {
      currentReadings[jointData["code"]] = jointData["initialAngle"].toInt();
    }
  }

  void saveStep() {
    List<String> step = [];
    currentReadings.forEach((code, value) => step.add("$code$value"));
    steps.add(step);
  }

  void setCurrentReading(String code, int value) {
    currentReadings[code] = value;
  }

  void saveProcess(String name) async {
    if (steps.isEmpty) return;
    emit(ControllerSaveProcessLoadingState());
    var result = await processStorageService.saveProcess(steps, name);
    result.fold(
        (failure) => emit(
              ControllerSaveProcessErrorState(failure.message),
            ), (id) {
      processes.add(AutomationProcess(steps, id, name));
      emit(ControllerSaveProcessSuccessState());
    });
    steps = [];
  }

  void getProcesses() async {
    emit(GetProcessesLoadingState());
    var result = await processStorageService.getProcesses();

    result.fold(
        (failure) => emit(
              GetProcessesErrorState(failure.message),
            ), (processes) {
      this.processes = processes;
      emit(GetProcessesSuccessState());
    });
  }

  void clearSteps() {
    steps = [];
  }

  Future<bool> deleteProcess(String id) async {
    emit(DeleteProcessLoadingState());
    var result = await processStorageService.deleteProcess(id);
    return result.fold(
        (failure) {
          emit(DeleteProcessErrorState(failure.message));
          return false;
        }, (_) {
      processes = processes.where((process) => process.uuid != id).toList();
      emit(ControllerSaveProcessSuccessState());
      return true;
    });
  }
}
