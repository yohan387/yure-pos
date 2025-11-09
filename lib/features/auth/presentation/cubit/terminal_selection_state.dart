import 'package:equatable/equatable.dart';
import 'package:todouapp/features/auth/domain/entities/terminal.dart';

enum TerminalSelectionStatus {
  initial,
  loading,
  success,
  failure,
}

class TerminalSelectionState extends Equatable {
  final TerminalSelectionStatus status;
  final List<Terminal> terminals;
  final Terminal? selectedTerminal;
  final String? message;

  const TerminalSelectionState({
    this.status = TerminalSelectionStatus.initial,
    this.terminals = const [],
    this.selectedTerminal,
    this.message,
  });

  TerminalSelectionState copyWith({
    TerminalSelectionStatus? status,
    List<Terminal>? terminals,
    Terminal? selectedTerminal,
    String? message,
  }) {
    return TerminalSelectionState(
      status: status ?? this.status,
      terminals: terminals ?? this.terminals,
      selectedTerminal: selectedTerminal ?? this.selectedTerminal,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, terminals, selectedTerminal, message];
}
