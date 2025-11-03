import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/network/i_network_info.dart';
import 'package:todouapp/features/profil/data/datasources/i_profil_data_source.dart';
import 'package:todouapp/features/profil/data/models/profil_model.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/i_profil_repository.dart';

/// Implémentation du repository de profil
class ProfilRepositoryImpl implements IProfilRepository {
  final IProfilDataSource _dataSource;
  final INetworkInfo _networkInfo;

  ProfilRepositoryImpl({
    required IProfilDataSource dataSource,
    required INetworkInfo networkInfo,
  })  : _dataSource = dataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, ProfilModel>> getProfil() async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final profil = await _dataSource.getProfil();
      return Right(profil);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
