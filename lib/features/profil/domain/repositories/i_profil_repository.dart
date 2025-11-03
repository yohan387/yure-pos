import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/profil/data/models/profil_model.dart';

abstract class IProfilRepository {
  Future<Either<Failure, ProfilModel>> getProfil();
}
