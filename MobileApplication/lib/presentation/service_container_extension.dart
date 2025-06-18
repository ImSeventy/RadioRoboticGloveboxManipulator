import 'package:get_it/get_it.dart';
import 'package:rrgbm/presentation/controller/bloc/cubits/controller_cubit.dart';

extension PresenstationServiceContainerExtension on GetIt {
  void initPresentationServices() {
    registerFactory<ControllerCubit>(
      () => ControllerCubit(
        processStorageService: this(),
      ),
    );
  }
}
