import 'dart:convert';

import 'package:rrgbm/infrastructure/data_providers/shared/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/AutomationProcess.dart';
import 'package:uuid/uuid.dart';

abstract class IProcessStorageProvider {
  Future<String> saveProcess(List<List<String>> steps, String name);
  Future<void> deleteProcess(String id);
  Future<List<AutomationProcess>> getProcesses();
}

class ProcessStorageProvider extends IProcessStorageProvider {
  final SharedPreferences sharedPreferences;
  final uuid = const Uuid();

  ProcessStorageProvider({required this.sharedPreferences});

  // @override
  // Future<AutomationProcess> getProcess(String uuid) async {
  //   List<String>? processesJsonData = sharedPreferences.getStringList(processesStorageKey);
  //
  //   if (processesJsonData == null) {
  //     throw AutomationProcessNotFoundException();
  //   }
  //
  //   String? jsonData = processesJsonData.firstWhere(())
  //
  //   Map<String, dynamic> data = jsonDecode(jsonData);
  //   return AutomationProcess(
  //     data["steps"],
  //     data["uuid"],
  //     data["name"],
  //   );
  // }

  @override
  Future<List<AutomationProcess>> getProcesses() async {
    List<String>? processesJsonData =
        sharedPreferences.getStringList(processesStorageKey);

    if (processesJsonData == null) return [];
    return processesJsonData.map((jsonData) => (jsonDecode(jsonData) as Map<String, dynamic>)).map(
          (data) {
            List<List<String>> steps = [];
            for (var step in (data["steps"] as List)) {
              steps.add((step as List).cast<String>());
            }
            return AutomationProcess(
              steps,
              data["uuid"],
              data["name"],
            );
          },
        ).toList();
  }

  @override
  Future<String> saveProcess(List<List<String>> steps, String name) async {
    String id = uuid.v4();

    var data = {
      "uuid": id,
      "name": name,
      "steps": steps
    };

    List<String> processesJsonData =
    sharedPreferences.getStringList(processesStorageKey) ?? [];
    processesJsonData.add(jsonEncode(data));
    sharedPreferences.setStringList(processesStorageKey, processesJsonData);

    return id;
  }

  @override
  Future<void> deleteProcess(String id) async {
    List<String>? processesJsonData =
    sharedPreferences.getStringList(processesStorageKey);

    if (processesJsonData == null) return;

    List<Map<String, dynamic>> processes = processesJsonData.map((jsonData) => (jsonDecode(jsonData) as Map<String, dynamic>)).where((data) => data["uuid"] != id).toList();

    sharedPreferences.setStringList(processesStorageKey, processes.map((data) => jsonEncode(data)).toList());

  }
}
