import 'package:dartz/dartz.dart';

import '../errors/failure.dart';

typedef ApiResult<T> = Future<Either<Failure, T>>;
