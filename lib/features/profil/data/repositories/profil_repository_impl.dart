import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/network/network_info.dart';
import 'package:todouapp/features/profil/data/datasources/profil_remote_data_source.dart';
import 'package:todouapp/features/profil/data/models/profil_model.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/profil_repository.dart';

class ProfilRepositoryImpl implements ProfilRepository {
  final ProfilRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProfilRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProfilModel>> getProfil() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final transactions = await remoteDataSource.getProfil();
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
