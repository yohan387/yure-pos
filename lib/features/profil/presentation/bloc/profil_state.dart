part of 'profil_bloc.dart';

enum ProfilStatus { initial, loading, success, failure }

class ProfilState extends Equatable {
  final ProfilStatus status;
  final ProfilModel? profil;
  final String? errorMessage;

  const ProfilState({
    this.status = ProfilStatus.initial,
    this.profil,
    this.errorMessage,
  });

  ProfilState copyWith({
    ProfilStatus? status,
    ProfilModel? profil,
    String? errorMessage,
  }) {
    return ProfilState(
      status: status ?? this.status,
      profil: profil ?? this.profil,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profil, errorMessage];
}
