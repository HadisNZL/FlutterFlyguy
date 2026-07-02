import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import 'pic_info_model.dart';
import 'push_config_model.dart';

part 'device_model.freezed.dart';
part 'device_model.g.dart';

@freezed
class DeviceModel with _$DeviceModel {
  @HiveType(typeId: 2, adapterName: 'DeviceModelAdapter')
  const factory DeviceModel({
    // 基本信息
    @HiveField(0) @JsonKey(name: 'AreaId') required int areaId,
    @HiveField(1) @JsonKey(name: 'DeviceId') required int deviceId,
    @HiveField(2) @JsonKey(name: 'OEMDeviceId') required String oemDeviceId,
    @HiveField(3) @JsonKey(name: 'Location') required String location,
    @HiveField(4) @JsonKey(name: 'OEMPin') String? oemPin,
    @HiveField(5) @JsonKey(name: 'ConnectionState') String? connectionState,
    @HiveField(6) @JsonKey(name: 'DeviceType') required String deviceType,
    @HiveField(7) @JsonKey(name: 'Model') String? model,
    @HiveField(8) @JsonKey(name: 'DeviceVersion') String? deviceVersion,
    @HiveField(9) @JsonKey(name: 'PushPlanVersion') int? pushPlanVersion,
    @HiveField(10) @JsonKey(name: 'OEM') String? oem,
    @HiveField(11) @JsonKey(name: 'ChannelNo') int? channelNo,

    // 报警和声音配置
    @HiveField(12) @JsonKey(name: 'AlarmSoundMode') int? alarmSoundMode,
    @HiveField(13) @JsonKey(name: 'AlarmSoundStatus') int? alarmSoundStatus,
    @HiveField(14) @JsonKey(name: 'MicStatus') int? micStatus,
    @HiveField(15) @JsonKey(name: 'PIRStatus') String? pirStatus,
    @HiveField(16) @JsonKey(name: 'BattryStatus') int? battryStatus,
    @HiveField(17) @JsonKey(name: 'Status') String? status,
    @HiveField(18) @JsonKey(name: 'Sensitivity') String? sensitivity,
    @HiveField(19) @JsonKey(name: 'CostStatus') int? costStatus,
    @HiveField(20) @JsonKey(name: 'PushPlanStatus') String? pushPlanStatus,

    // 升级和网络
    @HiveField(21) @JsonKey(name: 'NeedUpgrade') int? needUpgrade,
    @HiveField(22) @JsonKey(name: 'NeedUpgradeCamera') int? needUpgradeCamera,
    @HiveField(23) @JsonKey(name: 'NeedUpgradeStation') int? needUpgradeStation,
    @HiveField(24) @JsonKey(name: 'WifiQuality') int? wifiQuality,
    @HiveField(25) @JsonKey(name: 'WifiName') String? wifiName,
    @HiveField(26) @JsonKey(name: 'WifiLevel') int? wifiLevel,
    @HiveField(27) @JsonKey(name: 'StationId') String? stationId,

    // 时区和时间
    @HiveField(28) @JsonKey(name: 'Timezone') String? timezone,
    @HiveField(29) @JsonKey(name: 'TimezoneId') String? timezoneId,

    // 灯光配置
    @HiveField(30) @JsonKey(name: 'FlashLight') int? flashLight,
    @HiveField(31) @JsonKey(name: 'FlashLightMode') int? flashLightMode,
    @HiveField(32) @JsonKey(name: 'LightBeginTime') String? lightBeginTime,
    @HiveField(33) @JsonKey(name: 'LightEndTime') String? lightEndTime,
    @HiveField(34) @JsonKey(name: 'LightTimeRangeON') int? lightTimeRangeOn,

    // 心跳和音频
    @HiveField(35) @JsonKey(name: 'HeartbeatInterval') int? heartbeatInterval,
    @HiveField(36) @JsonKey(name: 'AlarmTone') int? alarmTone,
    @HiveField(37) @JsonKey(name: 'Mic') int? mic,
    @HiveField(38) @JsonKey(name: 'Sort') int? sort,
    @HiveField(39) @JsonKey(name: 'AlarmAudioFile') int? alarmAudioFile,
    @HiveField(40) @JsonKey(name: 'AlarmAudioBeginTime') String? alarmAudioBeginTime,
    @HiveField(41) @JsonKey(name: 'AlarmAudioEndTime') String? alarmAudioEndTime,

    // AI 配置
    @HiveField(42) @JsonKey(name: 'AISensitivity') String? aiSensitivity,
    @HiveField(43) @JsonKey(name: 'AIAlgorithm') int? aiAlgorithm,

    // 布防状态
    @HiveField(44) @JsonKey(name: 'ArmedAway') int? armedAway,
    @HiveField(45) @JsonKey(name: 'ArmedStay') int? armedStay,
    @HiveField(46) @JsonKey(name: 'Disarm') int? disarm,

    // P2P 配置
    @HiveField(47) @JsonKey(name: 'ReOemDeviceId') String? reOemDeviceId,
    @HiveField(48) @JsonKey(name: 'P2PId') String? p2pId,
    @HiveField(49) @JsonKey(name: 'P2PInitString') String? p2pInitString,
    @HiveField(50) @JsonKey(name: 'SecurtyKey') String? securtyKey,

    // 门禁和隐私
    @HiveField(51) @JsonKey(name: 'IsOpen') int? isOpen,
    @HiveField(52) @JsonKey(name: 'IsOpenPush') int? isOpenPush,
    @HiveField(53) @JsonKey(name: 'OpenDelayDuration') int? openDelayDuration,
    @HiveField(54) @JsonKey(name: 'IsMotionTracking') int? isMotionTracking,
    @HiveField(55) @JsonKey(name: 'Flip') int? flip,
    @HiveField(56) @JsonKey(name: 'IsRedFrame') int? isRedFrame,
    @HiveField(57) @JsonKey(name: 'Is24GOnly') int? is24GOnly,
    @HiveField(58) @JsonKey(name: 'SpeechModel') int? speechModel,
    @HiveField(59) @JsonKey(name: 'IsPrivacyMode') int? isPrivacyMode,

    // 电话和错误
    @HiveField(60) @JsonKey(name: 'PSTN') String? pstn,
    @HiveField(61) @JsonKey(name: 'TFError') int? tfError,
    @HiveField(62) @JsonKey(name: 'HumanFrameThreshold') int? humanFrameThreshold,
    @HiveField(63) @JsonKey(name: 'SipRegistered') int? sipRegistered,
    @HiveField(64) @JsonKey(name: 'AlarmSoundLevel') int? alarmSoundLevel,
    @HiveField(65) @JsonKey(name: 'IsAuto911Call') int? isAuto911Call,
    @HiveField(66) @JsonKey(name: 'CaptureConfig') String? captureConfig,

    // 嵌套对象（PushConfig 和 PicInfo）- 存储为 Map，避免 Hive 序列化问题
    @HiveField(67)
    @JsonKey(name: 'PushConfig')
    Map<String, dynamic>? pushConfig,
    @HiveField(68)
    @JsonKey(name: 'PicInfo')
    Map<String, dynamic>? picInfo,
  }) = _DeviceModel;

  const DeviceModel._();

  factory DeviceModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceModelFromJson(json);

  /// 获取强类型的 PushConfig（按需转换）
  PushConfigModel? get pushConfigModel {
    if (pushConfig == null) return null;
    try {
      return PushConfigModel.fromJson(pushConfig!);
    } catch (e) {
      return null;
    }
  }

  /// 获取强类型的 PicInfo（按需转换）
  PicInfoModel? get picInfoModel {
    if (picInfo == null) return null;
    try {
      return PicInfoModel.fromJson(picInfo!);
    } catch (e) {
      return null;
    }
  }

  /// 是否在线
  bool get isOnline => connectionState == 'online';

  /// 是否为摄像头类型
  bool get isCamera => deviceType == 'camera';

  /// 是否为传感器类型（红外探测器/门磁/平安通）
  bool get isSensor =>
      deviceType == 'motion' ||
      deviceType == 'door' ||
      deviceType == 'helpcall';
}
