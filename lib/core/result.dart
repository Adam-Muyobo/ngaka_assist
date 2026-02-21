// NgakaAssist
// Lightweight Result type used across repositories/usecases.
// Keeps error handling explicit without bringing in heavy dependencies.

class AppFailure {
  AppFailure({required this.message, this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() => 'AppFailure(code: $code, message: $message)';
}

class AppResult<T> {
  AppResult._({this.data, this.failure});

  final T? data;
  final AppFailure? failure;

  bool get isOk => failure == null;

  static AppResult<T> ok<T>(T data) => AppResult._(data: data);
  static AppResult<T> err<T>(AppFailure failure) => AppResult._(failure: failure);

  R when<R>({required R Function(T data) ok, required R Function(AppFailure f) err}) {
    final f = failure;
    if (f != null) return err(f);
    return ok(data as T);
  }
}
