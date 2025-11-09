import 'package:todouapp/core/types/future_result.dart';
import 'package:todouapp/features/auth/domain/entities/terminal.dart';
import 'package:todouapp/features/auth/domain/repositories/i_auth_repository.dart';

class GetMerchantTerminals {
  final IAuthRepository _repository;

  GetMerchantTerminals(this._repository);

  FutureResult<List<Terminal>> call() {
    return _repository.getMerchantTerminals();
  }
}
