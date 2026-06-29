import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/login_init/login_init_model.dart';
import '../constants/app_constants.dart';

final loginInitStorageProvider = Provider<LoginInitStorage>((ref) {
  return LoginInitStorage();
});

class LoginInitStorage {
  static const String _boxName = AppConstants.boxLoginInit;

  /// 保存 LoginInit 数据（按账号隔离）
  Future<void> save(int accountId, LoginInitModel data) async {
    final box = await Hive.openBox<LoginInitModel>(_boxName);
    await box.put(AppConstants.loginInitKey(accountId), data);
  }

  /// 获取 LoginInit 数据（按账号）
  Future<LoginInitModel?> get(int accountId) async {
    final box = await Hive.openBox<LoginInitModel>(_boxName);
    return box.get(AppConstants.loginInitKey(accountId));
  }

  /// 删除指定账号的缓存
  Future<void> delete(int accountId) async {
    final box = await Hive.openBox<LoginInitModel>(_boxName);
    await box.delete(AppConstants.loginInitKey(accountId));
  }

  /// 清除所有缓存
  Future<void> clearAll() async {
    final box = await Hive.openBox<LoginInitModel>(_boxName);
    await box.clear();
  }
}
