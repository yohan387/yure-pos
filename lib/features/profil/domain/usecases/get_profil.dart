import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/profil/data/models/profil_model.dart';
import 'package:todouapp/features/profil/domain/repositories/i_profil_repository.dart';

/// UseCase pour récupérer le profil du terminal
class GetProfil {
  final IProfilRepository _repository;

  GetProfil(IProfilRepository repository) : _repository = repository;

  Future<Either<Failure, ProfilModel>> call() async {
    return await _repository.getProfil();
  }
}
