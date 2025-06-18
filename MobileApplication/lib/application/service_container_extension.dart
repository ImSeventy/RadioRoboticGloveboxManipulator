import 'package:get_it/get_it.dart';
import 'package:rrgbm/application/services/process_storage/IProcessStorageService.dart';
import 'package:rrgbm/application/services/process_storage/ProcessStorageService.dart';

extension ServiceContainerExtension on GetIt {
  void initApplicationServices() {
    registerLazySingleton<IProcessStorageService>(
      () => ProcessStorageService(
        this(),
      ),
    );
  }
}
