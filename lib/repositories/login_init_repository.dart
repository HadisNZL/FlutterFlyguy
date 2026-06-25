import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/business_api.dart';
import '../core/storage/login_init_storage.dart';
import '../models/login_init/login_init_model.dart';

final loginInitRepositoryProvider = Provider<LoginInitRepository>((ref) {
  return LoginInitRepository(
    ref.watch(businessApiProvider),
    ref.watch(loginInitStorageProvider),
  );
});

class LoginInitRepository {
  LoginInitRepository(this._businessApi, this._storage);

  final BusinessApi _businessApi;
  final LoginInitStorage _storage;

  /// 请求 LoginInit 接口并缓存
  Future<LoginInitModel> getLoginInit() async {
    final response = await _businessApi.loginInit();
    final data = LoginInitModel.fromJson(response.data['Data']);

    // 缓存数据
    await _storage.save(data.accountInfo.accountId, data);

    return data;
  }

  /// 获取缓存的 LoginInit 数据
  Future<LoginInitModel?> getCachedLoginInit(int accountId) async {
    return _storage.get(accountId);
  }

  /// 清除指定账号的缓存
  Future<void> clearCache(int accountId) async {
    await _storage.delete(accountId);
  }

  /// 清除所有缓存
  Future<void> clearAllCache() async {
    await _storage.clearAll();
  }
}
