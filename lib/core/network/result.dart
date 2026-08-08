sealed class Result<T> {
  Result();
}

class Success<T> extends Result<T> {
  final T data;
  Success(this.data);
}

class Failure<T> extends Result<T> {
  Failure(this.message);
  final String message;
}
