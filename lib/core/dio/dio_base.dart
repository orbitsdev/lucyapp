import 'dart:io';
import 'package:bettingapp/config/api_config.dart';
import 'package:get/get.dart';
import 'package:bettingapp/controllers/auth_controller.dart';
import 'package:bettingapp/models/api_error.dart';
import 'package:dio/dio.dart' as dio;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fpdart/fpdart.dart';

class DioService {
  static final DioService _instance = DioService._internal();
  late dio.Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Connectivity _connectivity = Connectivity();
  
  static const String _tokenKey = 'access_token';
  static final String baseUrl = ApiConfig.stagingBaseUrl;
  static const String apiPrefix = '/api';

  factory DioService() {
    return _instance;
  }
  
  DioService._internal() {
    _initDio();
  }
  
  dio.Dio get client => _dio;
  
  void _initDio() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: 15000),
      receiveTimeout: const Duration(milliseconds: 15000),
      sendTimeout: const Duration(milliseconds: 15000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (dio.RequestOptions options, dio.RequestInterceptorHandler handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (dio.DioException error, dio.ErrorInterceptorHandler handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: _tokenKey);
          // Force logout via AuthController if available
          try {
            // Import is already available, so we can use Get.find
            final authController = Get.isRegistered<AuthController>()
                ? Get.find<AuthController>()
                : null;
            if (authController != null) {
              await authController.forceLogout(message: 'Session expired or invalid. Please login again.');
            }
          } catch (_) {}
        }
        return handler.next(error);
      },
    ));
    
    _setupConnectivity();
  }
  
  void _setupConnectivity() {
    _connectivity.onConnectivityChanged.listen((results) {
      bool isConnected = results.any((result) => result != ConnectivityResult.none);
      if (!isConnected) {
        print('Device is offline');
        // Show no internet modal if needed
        // Uncomment the line below if you want to show a modal automatically
        // Modal.showNoInternetModal();
      } else {
        print('Device is online');
      }
    });
  }
  
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      // Handle decryption error (e.g., after app reinstall or signing key change)
      if (e.toString().contains('BAD_DECRYPT')) {
        await _storage.deleteAll();
        // Optionally, you can log out the user or trigger a re-login here
        return null;
      }
      rethrow;
    }
  }
  
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
  
  String _ensureApiPrefix(String path) {
    if (!path.startsWith(apiPrefix)) {
      return '$apiPrefix$path';
    }
    return path;
  }
  
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        _ensureApiPrefix(path),
        queryParameters: queryParameters,
        options: options,
      );
      
      if (response.data is Map && response.data.containsKey('status')) {
        if (response.data['status'] == true) {
          return right(fromJson(response.data['data']));
        } else {
          return left(ApiError(
            message: response.data['message'] ?? 'Unknown error',
            data: response.data,
            statusCode: response.statusCode,
          ));
        }
      }
      
      return right(fromJson(response.data));
    } on dio.DioException catch (e) {
      return left(_handleDioError(e));
    } catch (e) {
      return left(ApiError(message: 'Unexpected error: ${e.toString()}'));
    }
  }
  
  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.post(
        _ensureApiPrefix(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      if (response.data is Map && response.data.containsKey('status')) {
        if (response.data['status'] == true) {
          return right(fromJson(response.data['data']));
        } else {
          return left(ApiError(
            message: response.data['message'] ?? 'Unknown error',
            data: response.data,
            statusCode: response.statusCode,
          ));
        }
      }
      
      return right(fromJson(response.data));
    } on dio.DioException catch (e) {
      return left(_handleDioError(e));
    } catch (e) {
      return left(ApiError(message: 'Unexpected error: ${e.toString()}'));
    }
  }
  
  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.put(
        _ensureApiPrefix(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      if (response.data is Map && response.data.containsKey('status')) {
        if (response.data['status'] == true) {
          return right(fromJson(response.data['data']));
        } else {
          return left(ApiError(
            message: response.data['message'] ?? 'Unknown error',
            data: response.data,
            statusCode: response.statusCode,
          ));
        }
      }
      
      return right(fromJson(response.data));
    } on dio.DioException catch (e) {
      return left(_handleDioError(e));
    } catch (e) {
      return left(ApiError(message: 'Unexpected error: ${e.toString()}'));
    }
  }
  
  Future<ApiResult<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        _ensureApiPrefix(path),
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      if (response.data is Map && response.data.containsKey('status')) {
        if (response.data['status'] == true) {
          return right(fromJson(response.data['data']));
        } else {
          return left(ApiError(
            message: response.data['message'] ?? 'Unknown error',
            data: response.data,
            statusCode: response.statusCode,
          ));
        }
      }
      
      return right(fromJson(response.data));
    } on dio.DioException catch (e) {
      return left(_handleDioError(e));
    } catch (e) {
      return left(ApiError(message: 'Unexpected error: ${e.toString()}'));
    }
  }
  

  
  // Authenticated API Methods
  Future<ApiResult<T>> authGet<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    required T Function(dynamic) fromJson,
  }) async {
    final token = await getToken();
    if (token == null) {
      return left(ApiError(
        message: 'Authentication required. Please login.',
        code: 'auth_required',
      ));
    }
    
    dio.Options requestOptions = options ?? dio.Options();
    requestOptions.headers = requestOptions.headers ?? {};
    requestOptions.headers!['Authorization'] = 'Bearer $token';
    
    try {
      final response = await _dio.get(
        _ensureApiPrefix(path),
        queryParameters: queryParameters,
        options: requestOptions,
      );
      
      print('AuthGet response: ${response.data}');
      
      if (response.data is Map && response.data.containsKey('status')) {
        if (response.data['status'] == true) {
          // Pass the entire response to fromJson to handle nested data
          return right(fromJson(response.data));
        } else {
          return left(ApiError(
            message: response.data['message'] ?? 'Unknown error',
            data: response.data,
            statusCode: response.statusCode,
          ));
        }
      }
      
      return right(fromJson(response.data));
    } on dio.DioException catch (e) {
      return left(_handleDioError(e));
    } catch (e) {
      return left(ApiError(message: 'Unexpected error: ${e.toString()}'));
    }
  }
  
  Future<ApiResult<T>> authPost<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    required T Function(dynamic) fromJson,
  }) async {
    final token = await getToken();
    if (token == null) {
      return left(ApiError(
        message: 'Authentication required. Please login.',
        code: 'auth_required',
      ));
    }
    
    dio.Options requestOptions = options ?? dio.Options();
    requestOptions.headers = requestOptions.headers ?? {};
    requestOptions.headers!['Authorization'] = 'Bearer $token';
    
    return post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
      fromJson: fromJson,
    );
  }
  
  Future<ApiResult<T>> authPut<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    required T Function(dynamic) fromJson,
  }) async {
    final token = await getToken();
    if (token == null) {
      return left(ApiError(
        message: 'Authentication required. Please login.',
        code: 'auth_required',
      ));
    }
    
    dio.Options requestOptions = options ?? dio.Options();
    requestOptions.headers = requestOptions.headers ?? {};
    requestOptions.headers!['Authorization'] = 'Bearer $token';
    
    return put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
      fromJson: fromJson,
    );
  }
  
  Future<ApiResult<T>> authDelete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    required T Function(dynamic) fromJson,
  }) async {
    final token = await getToken();
    if (token == null) {
      return left(ApiError(
        message: 'Authentication required. Please login.',
        code: 'auth_required',
      ));
    }
    
    dio.Options requestOptions = options ?? dio.Options();
    requestOptions.headers = requestOptions.headers ?? {};
    requestOptions.headers!['Authorization'] = 'Bearer $token';
    
    return delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
      fromJson: fromJson,
    );
  }
  
  // File Upload Method
  // File Upload Method
  Future<ApiResult<T>> uploadFile<T>(
    String path, {
    required File file,
    String fileFieldName = 'file',
    Map<String, dynamic>? fields,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.ProgressCallback? onSendProgress,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final formData = dio.FormData();
      
      formData.files.add(MapEntry(
        fileFieldName,
        await dio.MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      ));
      
      if (fields != null) {
        fields.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }
      
      dio.Options requestOptions = options ?? dio.Options();
      requestOptions.headers = requestOptions.headers ?? {};
      requestOptions.contentType = 'multipart/form-data';
      
      final response = await _dio.post(
        _ensureApiPrefix(path),
        data: formData,
        queryParameters: queryParameters,
        options: requestOptions,
        onSendProgress: onSendProgress,
      );
      
      if (response.data is Map && response.data.containsKey('status')) {
        if (response.data['status'] == true) {
          return right(fromJson(response.data['data']));
        } else {
          return left(ApiError(
            message: response.data['message'] ?? 'Unknown error',
            data: response.data,
            statusCode: response.statusCode,
          ));
        }
      }
      
      return right(fromJson(response.data));
    } on dio.DioException catch (e) {
      return left(_handleDioError(e));
    } catch (e) {
      return left(ApiError(message: 'Unexpected error: ${e.toString()}'));
    }
  }
  
  // Authenticated File Upload Method
  Future<ApiResult<T>> authUploadFile<T>(
    String path, {
    required File file,
    String fileFieldName = 'file',
    Map<String, dynamic>? fields,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.ProgressCallback? onSendProgress,
    required T Function(dynamic) fromJson,
  }) async {
    final token = await getToken();
    if (token == null) {
      return left(ApiError(
        message: 'Authentication required. Please login.',
        code: 'auth_required',
      ));
    }
    
    dio.Options requestOptions = options ?? dio.Options();
    requestOptions.headers = requestOptions.headers ?? {};
    requestOptions.headers!['Authorization'] = 'Bearer $token';
    
    return uploadFile<T>(
      path,
      file: file,
      fileFieldName: fileFieldName,
      fields: fields,
      queryParameters: queryParameters,
      options: requestOptions,
      onSendProgress: onSendProgress,
      fromJson: fromJson,
    );
  }
  
  ApiError _handleDioError(dio.DioException exception) {
    print('API error: ${exception.message}');
    print('Status code: ${exception.response?.statusCode}');
    print('Error data: ${exception.response?.data}');
    
    String message;
    String? code;
    int? statusCode = exception.response?.statusCode;
    
    // First check if we have a direct error message from the API
    if (exception.response?.data is Map && 
        exception.response!.data.containsKey('message')) {
      message = exception.response!.data['message'];
      code = exception.response!.data.containsKey('errors') ? 'validation_error' : 'api_error';

      // If 401, force logout
      if (statusCode == 401) {
        try {
          final authController = Get.isRegistered<AuthController>()
              ? Get.find<AuthController>()
              : null;
          if (authController != null) {
            authController.forceLogout(message: 'Session expired or invalid. Please login again.');
          }
        } catch (_) {}
      }
      
      return ApiError(
        message: message,
        code: code,
        statusCode: statusCode,
        data: exception.response?.data,
        exception: exception,
      );
    }
    
    switch (exception.type) {
      case dio.DioExceptionType.connectionTimeout:
      case dio.DioExceptionType.connectionTimeout:
      case dio.DioExceptionType.sendTimeout:
      case dio.DioExceptionType.receiveTimeout:
        message = 'Request timed out. Please try again.';
        code = 'timeout';
        break;
      case dio.DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        code = 'no_connection';
        break;
      case dio.DioExceptionType.badCertificate:
        message = 'SSL certificate error. Please try again.';
        code = 'bad_certificate';
        break;
      case dio.DioExceptionType.badResponse:
        if (statusCode == 401) {
          message = 'Unauthorized. Please login again.';
          code = 'unauthorized';
          // Force logout
          try {
            final authController = Get.isRegistered<AuthController>()
                ? Get.find<AuthController>()
                : null;
            if (authController != null) {
              authController.forceLogout(message: message);
            }
          } catch (_) {}
        } else if (statusCode == 404) {
          // Check if we have a custom message from the API
          if (exception.response?.data is Map && 
              exception.response!.data.containsKey('message')) {
            message = exception.response!.data['message'];
          } else {
            message = 'Resource not found.';
          }
          code = 'not_found';
        } else if (statusCode == 400) {
          message = 'Bad request. Please check your input.';
          code = 'bad_request';
        } else if (statusCode == 422) {
          message = 'Validation error. Please check your input.';
          code = 'validation_error';
        } else {
          message = 'Server error. Please try again later.';
          code = 'server_error';
        }
        break;
      case dio.DioExceptionType.cancel:
        message = 'Request was cancelled.';
        code = 'cancelled';
        break;
      default:
        message = 'An unexpected error occurred. Please try again.';
        code = 'unknown';
        break;
    }
    
    return ApiError(
      message: message,
      code: code,
      statusCode: statusCode,
      data: exception.response?.data,
      exception: exception,
    );
  }
  
  
}

