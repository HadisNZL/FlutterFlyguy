import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/api_config.dart';
import '../storage/token_storage.dart';
import 'interceptors/auth_interceptor.dart';

class DioClient {
  /// 创建认证服务的 Dio 实例
  static Dio createAuth({TokenStorage? tokenStorage}) {
    return _create(baseUrl: ApiConfig.authBaseUrl, tokenStorage: tokenStorage);
  }

  /// 创建业务服务的 Dio 实例
  static Dio createBusiness({TokenStorage? tokenStorage}) {
    return _create(
      baseUrl: ApiConfig.businessBaseUrl,
      tokenStorage: tokenStorage,
    );
  }

  /// 内部统一创建方法
  static Dio _create({required String baseUrl, TokenStorage? tokenStorage}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
      ),
    );

    // 配置 HttpClient
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();

        // Debug 模式下配置 Android 代理（用于 Charles 抓包）
        if (kDebugMode && Platform.isAndroid) {
          client.findProxy = (uri) => 'PROXY 192.168.201.1:8888';
        }

        // 允许不安全证书（HTTP 明文传输 + 自签名证书）
        client.badCertificateCallback = (cert, host, port) => true;

        return client;
      },
    );

    // 添加认证拦截器（自动添加所有必要的 Header）
    if (tokenStorage != null) {
      dio.interceptors.add(AuthInterceptor(tokenStorage));
    }

    // 根据环境配置启用日志
    if (ApiConfig.enableLogger) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: true,
        ),
      );
    }

    return dio;
  }
}
