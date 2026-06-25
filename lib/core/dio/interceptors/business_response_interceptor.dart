import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/global/global_error_provider.dart';
import '../../constants/error_codes.dart';
import '../../exceptions/business_exceptions.dart';

/// 业务接口响应拦截器
/// 统一处理业务层的错误码（IsSuccess、ErrorCode）
class BusinessResponseInterceptor extends Interceptor {
  BusinessResponseInterceptor(this.ref);

  final Ref ref;

  /// 特殊错误码映射表
  /// 错误码 → 异常工厂函数
  static final _errorCodeMap = <int, GlobalHandledException Function(Map<String, dynamic>)>{
    BusinessErrorCode.accountConflict: (data) => AccountConflictException(
          latestDevice: data['LatestDevice'] as String? ?? '未知设备',
          latestLoginTime: _formatTime(data['LatestLoginTime'] as String? ?? ''),
          message: '账号在其他设备登录',
        ),
    // 未来新增特殊错误码，只需在此添加映射
  };

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;

    // 只处理业务接口的响应格式 {IsSuccess, Data, Message, ErrorCode, ErrorDomain}
    if (data is Map && data.containsKey('IsSuccess')) {
      final isSuccess = data['IsSuccess'] as bool? ?? false;
      final message = data['Message'] as String? ?? '';
      final errorCode = data['ErrorCode'] as int? ?? 0;

      // 业务失败
      if (!isSuccess) {
        // 查表：是否为特殊错误码
        final exceptionFactory = _errorCodeMap[errorCode];

        if (exceptionFactory != null) {
          // 特殊错误：创建异常对象
          final exception = exceptionFactory(data['Data'] as Map<String, dynamic>? ?? {});

          // 判断是否为退出登录（退出时不推送全局）
          final isLogoutRequest = response.requestOptions.path.contains('/logout');
          if (!isLogoutRequest) {
            ref.read(globalErrorProvider.notifier).notify(exception);
          }

          // reject 异常
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: exception,
            ),
          );
          return;
        }

        // 普通业务错误
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

  /// 格式化时间 "/Date(1782287436000)/" -> "2026-06-25 10:30:36"
  static String _formatTime(String dateString) {
    try {
      final timestamp = int.parse(dateString.replaceAll(RegExp(r'[^\d]'), ''));
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}:'
          '${date.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
