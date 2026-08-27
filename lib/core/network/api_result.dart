import 'network_exceptions.dart';

sealed class ApiResult<T> {
  const ApiResult();

  factory ApiResult.success(T data) = Success<T>;
  factory ApiResult.failure(NetworkException exception) = Failure<T>;

  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(NetworkException exception) onFailure,
  }) {
    switch (this) {
      case Success(:final data):
        return onSuccess(data);
      case Failure(:final exception):
        return onFailure(exception);
    }
  }

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;
}

class Success<T> extends ApiResult<T> {
  final T data;

  const Success(this.data);
}

class Failure<T> extends ApiResult<T> {
  final NetworkException exception;

  const Failure(this.exception);
}
