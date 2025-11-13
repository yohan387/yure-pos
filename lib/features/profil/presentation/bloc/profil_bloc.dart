import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todouapp/features/profil/domain/usecases/get_profil.dart';

import '../../data/models/profil_model.dart';

part 'profil_event.dart';
part 'profil_state.dart';

class ProfilBloc extends Bloc<ProfilEvent, ProfilState> {
  final GetProfil getProfil;

  ProfilBloc({
    required this.getProfil,
  }) : super(const ProfilState()) {
    on<LoadProfilEvent>(_onLoadProfil);
  }

  Future<void> _onLoadProfil(
    LoadProfilEvent event,
    Emitter<ProfilState> emit,
  ) async {
    emit(state.copyWith(status: ProfilStatus.loading));

    final result = await getProfil();

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProfilStatus.failure,
        errorMessage: failure.message,
      )),
      (balance) => emit(state.copyWith(
        status: ProfilStatus.success,
        profil: balance,
      )),
    );
  }
}
