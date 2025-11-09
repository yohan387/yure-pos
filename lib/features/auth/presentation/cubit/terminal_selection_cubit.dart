import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todouapp/core/utils/secure_storage.dart';
import 'package:todouapp/features/auth/domain/entities/terminal.dart';
import 'package:todouapp/features/auth/domain/usecases/get_merchant_terminals.dart';
import 'package:todouapp/features/auth/presentation/cubit/terminal_selection_state.dart';

class TerminalSelectionCubit extends Cubit<TerminalSelectionState> {
  final GetMerchantTerminals _getMerchantTerminals;
  final SecureStorageService _secureStorage;

  TerminalSelectionCubit({
    required GetMerchantTerminals getMerchantTerminals,
    required SecureStorageService secureStorage,
  })  : _getMerchantTerminals = getMerchantTerminals,
        _secureStorage = secureStorage,
        super(const TerminalSelectionState());

  Future<void> loadTerminals() async {
    emit(state.copyWith(status: TerminalSelectionStatus.loading));

    final result = await _getMerchantTerminals();

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: TerminalSelectionStatus.failure,
          message: failure.message,
        ));
      },
      (terminals) {
        if (terminals.isEmpty) {
          emit(state.copyWith(
            status: TerminalSelectionStatus.failure,
            message: 'Aucun terminal assigné',
          ));
        } else {
          emit(state.copyWith(
            status: TerminalSelectionStatus.success,
            terminals: terminals,
          ));
        }
      },
    );
  }

  void selectTerminal(Terminal terminal) {
    emit(state.copyWith(selectedTerminal: terminal));
  }

  Future<void> confirmSelection() async {
    if (state.selectedTerminal != null) {
      // Save selected terminal to secure storage
      await _secureStorage.saveSelectedTerminal(state.selectedTerminal!.id);
    }
  }

  void reset() {
    emit(const TerminalSelectionState());
  }
}
