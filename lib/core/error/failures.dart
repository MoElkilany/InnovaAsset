/// Base sealed class for all failures in the app.
sealed class Failure {
  final String message;
  const Failure(this.message);
}

/// Network-related failures (API calls, connectivity issues).
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Cache-related failures (Hive read/write, empty cache).
final class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Validation failures (form, input validation).
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
