import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';

typedef FutureResult<T> = Future<Either<Failure, T>>;
