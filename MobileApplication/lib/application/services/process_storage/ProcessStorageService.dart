import 'package:dartz/dartz.dart';
import 'package:rrgbm/application/errors/BaseError.dart';
import 'package:rrgbm/application/errors/process_storage_errors.dart';
import 'package:rrgbm/application/services/process_storage/IProcessStorageService.dart';
import 'package:rrgbm/domain/models/AutomationProcess.dart';
import 'package:rrgbm/infrastructure/data_providers/ProcessStorageProvider.dart';

class ProcessStorageService extends IProcessStorageService {
  final IProcessStorageProvider processStorageProvider;

  ProcessStorageService(this.processStorageProvider);

  @override
  Future<Either<BaseError, List<AutomationProcess>>> getProcesses() async {
    try {
      var processes = await processStorageProvider.getProcesses();
      return Right(processes);
    } catch (_) {
      return Left(FetchingProcessesError());
    }
  }

  @override
  Future<Either<BaseError, String>> saveProcess(List<List<String>> steps, String name) async {
    try {
      var id = await processStorageProvider.saveProcess(steps, name);
      return Right(id);
    } catch (_) {
      return Left(SavingProcessError());
    }
  }

  @override
  Future<Either<BaseError, void>> deleteProcess(String id) async {
    try {
      await processStorageProvider.deleteProcess(id);
      return const Right(null);
    } catch (_) {
      return Left(SavingProcessError());
    }
  }

}