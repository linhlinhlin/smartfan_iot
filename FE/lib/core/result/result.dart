sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final String? code; // Ví dụ: 'NETWORK_ERROR', 'TIMEOUT'
  
  const Failure(this.message, {this.code});
}
