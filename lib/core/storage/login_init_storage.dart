import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/login_init/login_init_model.dart';

final loginInitStorageProvider = Provider<LoginInitStorage>((ref) {
  return LoginInitStorage();
});

class LoginInitStorage {
  static const String _boxName = 'login_init';

  /// 保存 LoginInit 数据（按账号隔离）
  Future<void> save(int accountId, LoginInitModel data) async {
    final box = await Hive.openBox<LoginInitModel>(_boxName);
    await box.put('account_$accountId', data);
  }

  /// 获取 LoginInit 数据（按账号）
  Future<LoginInitModel?> get(int accountId) async {
    final box = await Hive.openBox<LoginInitModel>(_boxName);
    return box.get('account_$accountId');
  }

  /// 删除指定账号的缓存
  Future<void> delete(int accountId) async {
    final box = await Hive.openBox<LoginInitModel>(_boxName);
    await box.delete('account_$accountId');
  }

  /// 清除所有缓存
  Future<void> clearAll() async {
    final box = await Hive.openBox<LoginInitModel>(_boxName);
    await box.clear();
  }
}
