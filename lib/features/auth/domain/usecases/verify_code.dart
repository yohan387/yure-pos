import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:todouapp/features/auth/data/models/auth_response_model.dart';

class VerifyCode {
  final AuthRepository repository;

  VerifyCode(this.repository);

  Future<Either<Failure, AuthResponseModel>> call(String code) async {
    return await repository.verifyCode(code);
  }
}
