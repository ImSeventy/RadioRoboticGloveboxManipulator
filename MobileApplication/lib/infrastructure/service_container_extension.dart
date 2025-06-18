import 'package:get_it/get_it.dart';
import 'package:rrgbm/infrastructure/data_providers/ProcessStorageProvider.dart';

extension PresenstationServiceContainerExtension on GetIt {
  void initInfrastructureServices() {
    registerLazySingleton<IProcessStorageProvider>(
      () => ProcessStorageProvider(
        sharedPreferences: this(),
      ),
    );
  }
}
