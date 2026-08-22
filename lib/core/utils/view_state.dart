/// Generic UI state used by every feature provider in this module set.
enum ViewStatus { initial, loading, loaded, empty, error }

/// Simple failure wrapper returned by mock repositories instead of throwing,
/// so providers can map it to an error UI state without try/catch sprawl.
class AppFailure {
  final String message;
  const AppFailure(this.message);

  @override
  String toString() => message;
}

/// Result<T> ??" success holds data, failure holds an AppFailure.
class Result<T> {
  final T? data;
  final AppFailure? failure;
  final bool isSuccess;

  const Result._({this.data, this.failure, required this.isSuccess});

  factory Result.success(T data) => Result._(data: data, isSuccess: true);
  factory Result.failure(AppFailure failure) =>
      Result._(failure: failure, isSuccess: false);
}

