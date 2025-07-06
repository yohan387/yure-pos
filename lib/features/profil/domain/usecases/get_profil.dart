import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/profil/data/models/profil_model.dart';
import 'package:todouapp/features/profil/domain/repositories/profil_repository.dart';

class GetProfil {
  final ProfilRepository repository;

  GetProfil(this.repository);

  Future<Either<Failure, ProfilModel>> call() async {
    return await repository.getProfil();
  }
}
