import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_endpoints.dart';
import '../core/dio/dio_client.dart';
import '../core/storage/token_storage.dart';

final businessApiProvider = Provider<BusinessApi>((ref) {
  final dio = DioClient.createBusiness(
    ref: ref,
    tokenStorage: ref.watch(tokenStorageProvider),
  );
  return BusinessApi(dio);
});

class BusinessApi {
  BusinessApi(this._dio);
  final Dio _dio;

  /// 获取登录初始化信息
  /// 返回格式：{IsSuccess, Data, Message, ErrorCode, ErrorDomain}
  Future<Response> loginInit() async {
    return _dio.get(ApiEndpoints.business.loginInit);
  }

  /// 退出登录
  /// 返回格式：{IsSuccess, Data, Message, ErrorCode, ErrorDomain}
  Future<void> logout() async {
    await _dio.post(ApiEndpoints.business.logout);
  }
}
