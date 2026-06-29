import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/auth/token_model.dart';
import '../constants/app_constants.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

class TokenStorage {
  static const String _boxName = AppConstants.boxAuthToken;
  static const String _tokenKey = AppConstants.keyToken;

  Box<TokenModel>? _box;

  /// 初始化 Box（延迟打开）
  Future<Box<TokenModel>> _ensureBox() async {
    _box ??= await Hive.openBox<TokenModel>(_boxName);
    return _box!;
  }

  /// 获取令牌
  Future<TokenModel?> getToken() async {
    final box = await _ensureBox();
    return box.get(_tokenKey);
  }

  /// 保存令牌
  Future<void> saveToken(TokenModel token) async {
    final box = await _ensureBox();
    await box.put(_tokenKey, token);
  }

  /// 清空令牌
  Future<void> clearToken() async {
    final box = await _ensureBox();
    await box.delete(_tokenKey);
  }
}
