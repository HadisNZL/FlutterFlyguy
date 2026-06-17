---
description: 快速添加常用的 Dio 拦截器（Token、刷新、重试、错误处理）。用于配置网络层中间件。
---

# add-interceptor

为 Dio 客户端添加常用的拦截器，提升网络层功能。

## 使用方式

```bash
/add-interceptor token    # Token 自动注入
/add-interceptor refresh  # Token 刷新
/add-interceptor retry    # 请求重试
/add-interceptor error    # 统一错误处理
```

## 支持的拦截器类型

### 1. Token 拦截器 (`token`)

自动在请求头中注入 JWT Token。

**生成位置**：`lib/core/dio/interceptors/token_interceptor.dart`

```dart
import 'package:dio/dio.dart';

class TokenInterceptor extends Interceptor {
  TokenInterceptor(this._getToken);

  final Future<String?> Function() _getToken;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

**使用示例**：
```dart
final dio = DioClient.create();
dio.interceptors.add(TokenInterceptor(() async {
  // 从本地存储获取 token
  return await storage.read('auth_token');
}));
```

---

### 2. Token 刷新拦截器 (`refresh`)

自动处理 401 错误并刷新 Token。

**生成位置**：`lib/core/dio/interceptors/refresh_interceptor.dart`

```dart
import 'package:dio/dio.dart';

class RefreshInterceptor extends Interceptor {
  RefreshInterceptor({
    required this.refreshToken,
    required this.onTokenRefreshed,
  });

  final Future<String> Function() refreshToken;
  final Future<void> Function(String token) onTokenRefreshed;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final newToken = await refreshToken();
        await onTokenRefreshed(newToken);

        // 重试原请求
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';
        final response = await Dio().fetch(opts);
        return handler.resolve(response);
      } catch (e) {
        return handler.reject(err);
      }
    }
    handler.next(err);
  }
}
```

**使用示例**：
```dart
dio.interceptors.add(RefreshInterceptor(
  refreshToken: () async {
    final response = await dio.post('/auth/refresh');
    return response.data['token'];
  },
  onTokenRefreshed: (token) async {
    await storage.write('auth_token', token);
  },
));
```

---

### 3. 重试拦截器 (`retry`)

网络请求失败时自动重试。

**生成位置**：`lib/core/dio/interceptors/retry_interceptor.dart`

```dart
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    this.retries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  final int retries;
  final Duration retryDelay;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    var extra = err.requestOptions.extra;
    var retriesLeft = extra['retries'] ?? retries;

    if (retriesLeft > 0 && _shouldRetry(err)) {
      extra['retries'] = retriesLeft - 1;
      err.requestOptions.extra = extra;

      await Future.delayed(retryDelay);

      try {
        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}
```

**使用示例**：
```dart
dio.interceptors.add(RetryInterceptor(
  retries: 3,
  retryDelay: Duration(seconds: 2),
));
```

---

### 4. 错误处理拦截器 (`error`)

统一处理 HTTP 错误，转换为友好的错误消息。

**生成位置**：`lib/core/dio/interceptors/error_interceptor.dart`

```dart
import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '连接超时，请检查网络';
        break;
      case DioExceptionType.badResponse:
        message = _handleStatusCode(err.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        break;
      default:
        message = '网络异常，请稍后重试';
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: message,
        type: err.type,
      ),
    );
  }

  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '拒绝访问';
      case 404:
        return '请求的资源不存在';
      case 500:
        return '服务器错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务不可用';
      default:
        return '请求失败 ($statusCode)';
    }
  }
}
```

**使用示例**：
```dart
dio.interceptors.add(ErrorInterceptor());
```

---

## 拦截器组合使用

在 `lib/core/dio/dio_client.dart` 中组合使用：

```dart
class DioClient {
  static Dio create({String? baseUrl}) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? 'https://api.example.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // 按顺序添加拦截器
    dio.interceptors.addAll([
      TokenInterceptor(() async => await getToken()),
      RefreshInterceptor(
        refreshToken: () async => await refreshToken(),
        onTokenRefreshed: (token) async => await saveToken(token),
      ),
      RetryInterceptor(retries: 3),
      ErrorInterceptor(),
      if (kDebugMode) PrettyDioLogger(),
    ]);

    return dio;
  }
}
```

## 注意事项

- 拦截器顺序很重要：Token → Refresh → Retry → Error → Logger
- Token 刷新拦截器会创建新的 Dio 实例，避免循环调用
- 重试拦截器只对网络超时类错误生效
- 错误消息可根据项目需求自定义
