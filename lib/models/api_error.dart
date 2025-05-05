
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

/// Represents the result of an API call using Either from fpdart
/// Left: ApiError for failures
/// Right: T for success data
typedef ApiResult<T> = Either<ApiError, T>;

/// Represents API errors with detailed information
class ApiError {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic data;
  final DioException? exception;

  ApiError({
    required this.message,
    this.code,
    this.statusCode,
    this.data,
    this.exception,
  });

  @override
  String toString() => 'ApiError(message: $message, code: $code, statusCode: $statusCode)';
}
