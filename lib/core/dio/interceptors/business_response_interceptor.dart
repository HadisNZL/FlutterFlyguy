import 'package:dio/dio.dart';

/// 业务接口响应拦截器
/// 统一处理业务层的错误码（IsSuccess、ErrorCode）
class BusinessResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;

    // 只处理业务接口的响应格式 {IsSuccess, Data, Message, ErrorCode, ErrorDomain}
    if (data is Map && data.containsKey('IsSuccess')) {
      final isSuccess = data['IsSuccess'] as bool? ?? false;
      final message = data['Message'] as String? ?? '';
      final errorCode = data['ErrorCode'] as int? ?? 0;

      // 业务失败，转换为 DioException
      if (!isSuccess) {
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: {
              'message': message,
              'errorCode': errorCode,
              'errorDomain': data['ErrorDomain'] ?? '',
            },
          ),
        );
        return;
      }
    }

    // 业务成功或非业务接口，直接放行
    handler.next(response);
  }
}
