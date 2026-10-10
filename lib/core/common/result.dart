import 'package:connect_hub/core/common/app_exception.dart';

/// The outcome of an operation that can fail: [Ok] with a value, or [Err]
/// with the [AppException] that explains the failure.
///
/// Repositories return a `Result` instead of throwing, so callers handle
/// failure as an ordinary value. Because the class is `sealed`, an exhaustive
/// `switch` makes forgetting the error case a compile error:
///
/// ```dart
/// switch (await login(email: email, password: password)) {
///   case Ok(:final value): open(value);
///   case Err(:final exception): showError(exception.message);
/// }
/// ```
sealed class Result<T> {
  const Result();
}

/// Success, carrying [value]. Declared with a Dart 3.13 primary constructor.
final class const Ok<T>(final T value) extends Result<T>;

/// Failure, carrying the [exception] that explains it.
final class const Err<T>(final AppException exception) extends Result<T>;
