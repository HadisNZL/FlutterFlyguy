import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_endpoints.dart';
import '../core/dio/dio_client.dart';
import '../core/storage/token_storage.dart';

final deviceApiProvider = Provider<DeviceApi>((ref) {
  final dio = DioClient.createBusiness(
    ref: ref,
    tokenStorage: ref.watch(tokenStorageProvider),
  );
  return DeviceApi(dio);
});

class DeviceApi {
  DeviceApi(this._dio);
  final Dio _dio;

  /// 获取设备列表
  /// 参数：areaId - 防区 ID
  /// 返回格式：{IsSuccess, Data: {Devices: [...]}, Message, ErrorCode, ErrorDomain}
  Future<Response> getDevices(int areaId) async {
    return _dio.get(
      ApiEndpoints.business.getDevices,
      queryParameters: {'areaId': areaId},
    );
  }
}
