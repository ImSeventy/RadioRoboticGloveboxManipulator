import 'package:get_it/get_it.dart';
import 'package:rrgbm/application/service_container_extension.dart';
import 'package:rrgbm/infrastructure/service_container_extension.dart';
import 'package:rrgbm/presentation/service_container_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt getIt = GetIt.instance;

Future<void> setUp() async {
  getIt.initInfrastructureServices();
  getIt.initApplicationServices();
  getIt.initPresentationServices();
  await _setUpCore();
}

Future<void> _setUpCore() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
}