import 'package:rrgbm/application/errors/BaseError.dart';
import 'package:dartz/dartz.dart';
import 'package:rrgbm/domain/models/AutomationProcess.dart';

abstract class IProcessStorageService {
  Future<Either<BaseError, String>> saveProcess(List<List<String>> steps, String name);
  Future<Either<BaseError, List<AutomationProcess>>> getProcesses();
  Future<Either<BaseError, void>> deleteProcess(String id);
}