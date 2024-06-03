import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:urven/data/configs/app_config.dart';
import 'package:urven/data/preferences/preferences_manager.dart';


class DioService {
  late Dio _dio;
  BaseOptions? _baseOptions;
  final Map<String, String> _baseHeaders = {};

  static final DioService _instance = DioService.internal();

  DioService.internal() {
    _baseOptions = BaseOptions(
      baseUrl: AppConfigs.API_BASE_URL,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      validateStatus: (status) {
        if (status == null) return false;
        return status < 500;
      },
    );

    _dio = Dio(_baseOptions);

    if (AppConfigs.IS_DEBUG) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  factory DioService() => _instance;

  Future<void> updateToken() async {
    String? token = PreferencesManager.instance.getAccessToken();
    if (token != null) {
      _baseHeaders['Authorization'] = 'Bearer $token';
      _baseOptions?.headers = _baseHeaders;
    } else {
      _baseHeaders.remove('Authorization');
      _baseOptions?.headers = _baseHeaders;
    }
  }

  Future get({
    required String path,
    Map<String, dynamic>? requestParams,
  }) async {
    await updateToken();
    return (await _dio.get(
      path,
      queryParameters: requestParams,
    ))
        .data;
  }

  Future post({
    required String path,
    Map<String, dynamic>? requestParams,
    Map<String, dynamic>? body,
    FormData? data,
  }) async {
    await updateToken();
    return (await _dio.post(
      path,
      queryParameters: requestParams,
      data: data ?? body,
    ))
        .data;
  }

  Future postFile({
    required String path,
    Map<String, dynamic>? requestParams,
    FormData? formData,
  }) async {
    await updateToken();
    return (await _dio.post(
      path,
      queryParameters: requestParams,
      data: formData,
    ))
        .data;
  }

  Future put({
    required String path,
    Map<String, dynamic>? requestParams,
    Map<String, dynamic>? body,
  }) async {
    await updateToken();
    return (await _dio.put(
      path,
      queryParameters: requestParams,
      data: body,
    ))
        .data;
  }

  Future patch({
    required String path,
    Map<String, dynamic>? requestParams,
    Map? body,
  }) async {
    await updateToken();
    return (await _dio.patch(
      path,
      queryParameters: requestParams,
      data: jsonEncode(body),
    ))
        .data;
  }

  Future delete({
    required String path,
    Map<String, dynamic>? requestParams,
  }) async {
    await updateToken();
    return (await _dio.delete(
      path,
      queryParameters: requestParams,
      data: FormData(),
    ))
        .data;
  }
}


