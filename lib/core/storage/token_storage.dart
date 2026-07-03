import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/auth/token_model.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

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

  /// 获取令牌（异步）
  Future<TokenModel?> getToken() async {
    final box = await _ensureBox();
    return box.get(_tokenKey);
  }

  /// 获取令牌（同步）
  ///
  /// 注意：Box 必须已经在 main() 中打开
  /// 如果 box 未打开，返回 null
  TokenModel? getTokenSync() {
    if (_box == null) {
      // 尝试获取已打开的 box
      try {
        if (Hive.isBoxOpen(_boxName)) {
          _box = Hive.box<TokenModel>(_boxName);
        } else {
          AppLogger.w(
            'Token box 未打开，无法同步获取 token',
            tag: LogTag.storage,
          );
          return null;
        }
      } catch (e) {
        AppLogger.e(
          '同步获取 token 失败',
          tag: LogTag.storage,
          error: e,
        );
        return null;
      }
    }

    return _box!.get(_tokenKey);
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
