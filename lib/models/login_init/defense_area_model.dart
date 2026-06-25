import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'defense_area_model.freezed.dart';
part 'defense_area_model.g.dart';

@freezed
class DefenseArea with _$DefenseArea {
  @HiveType(typeId: 6, adapterName: 'DefenseAreaAdapter')
  const factory DefenseArea({
    @HiveField(0) @JsonKey(name: 'AreaId') required int areaId,
    @HiveField(1) @JsonKey(name: 'AreaName') required String areaName,
    @HiveField(3) @JsonKey(name: 'UserLevel') required String userLevel,
    @HiveField(4) @JsonKey(name: 'DeviceCount') required int deviceCount,
    @HiveField(5) @JsonKey(name: 'Mode') required String mode,
    @HiveField(6) @JsonKey(name: 'Delaying') required int delaying,
    @HiveField(7) @JsonKey(name: 'AlarmStatus') required String alarmStatus,
    @HiveField(8) @JsonKey(name: 'AFAddress') required AFAddress address,
    @HiveField(9) @JsonKey(name: 'TimeZoneInfo') required TimeZoneInfo timeZone,
    @HiveField(10)
    @JsonKey(name: 'OEMAccountList')
    required List<OEMAccount> oemAccountList,
    @HiveField(11) @JsonKey(name: 'E911Valid') required bool e911Valid,
    @HiveField(12)
    @JsonKey(name: 'E911InvalidReason')
    required int e911InvalidReason,
    @HiveField(13)
    @JsonKey(name: 'AwayDelayDuration')
    required int awayDelayDuration,
    @HiveField(14)
    @JsonKey(name: 'StayDelayDuration')
    required int stayDelayDuration,
    @HiveField(15)
    @JsonKey(name: 'AlarmSirenDuration')
    required int alarmSirenDuration,
    @HiveField(16)
    @JsonKey(name: 'AlarmSirenDelayDuration')
    required int alarmSirenDelayDuration,
    @HiveField(17) @JsonKey(name: 'IVRLanguage') required String ivrLanguage,
    @HiveField(18)
    @JsonKey(name: 'EmpowerSubAccount')
    required int empowerSubAccount,
    @HiveField(19)
    @JsonKey(name: 'SensorDeviceCostStatus')
    required int sensorDeviceCostStatus,
    @HiveField(2) @JsonKey(name: 'Tag') String? tag,
  }) = _DefenseArea;

  factory DefenseArea.fromJson(Map<String, dynamic> json) =>
      _$DefenseAreaFromJson(json);
}

@freezed
class AFAddress with _$AFAddress {
  @HiveType(typeId: 7, adapterName: 'AFAddressAdapter')
  const factory AFAddress({
    @HiveField(0) @JsonKey(name: 'AddressType') required int addressType,
    @HiveField(8) @JsonKey(name: 'PSTN') required PSTN pstn,
    @HiveField(1) @JsonKey(name: 'StreetNumber') String? streetNumber,
    @HiveField(2) @JsonKey(name: 'StreetName') String? streetName,
    @HiveField(3) @JsonKey(name: 'AddressLine') String? addressLine,
    @HiveField(4) @JsonKey(name: 'City') String? city,
    @HiveField(5) @JsonKey(name: 'State') String? state,
    @HiveField(6) @JsonKey(name: 'Country') String? country,
    @HiveField(7) @JsonKey(name: 'Zip') String? zip,
  }) = _AFAddress;

  factory AFAddress.fromJson(Map<String, dynamic> json) =>
      _$AFAddressFromJson(json);
}

@freezed
class PSTN with _$PSTN {
  @HiveType(typeId: 8, adapterName: 'PSTNAdapter')
  const factory PSTN({
    @HiveField(0) @JsonKey(name: 'DID') String? did,
    @HiveField(1) @JsonKey(name: 'CountryCode') String? countryCode,
  }) = _PSTN;

  factory PSTN.fromJson(Map<String, dynamic> json) => _$PSTNFromJson(json);
}

@freezed
class TimeZoneInfo with _$TimeZoneInfo {
  @HiveType(typeId: 9, adapterName: 'TimeZoneInfoAdapter')
  const factory TimeZoneInfo({
    @HiveField(0) @JsonKey(name: 'IsDLS') required int isDLS,
    @HiveField(1) @JsonKey(name: 'TimeZone') required String timeZone,
    @HiveField(2) @JsonKey(name: 'TimeZoneDesc') required String timeZoneDesc,
    @HiveField(3) @JsonKey(name: 'TimeZoneID') required String timeZoneID,
  }) = _TimeZoneInfo;

  factory TimeZoneInfo.fromJson(Map<String, dynamic> json) =>
      _$TimeZoneInfoFromJson(json);
}

@freezed
class OEMAccount with _$OEMAccount {
  @HiveType(typeId: 10, adapterName: 'OEMAccountAdapter')
  const factory OEMAccount({
    @HiveField(1) @JsonKey(name: 'OEM') required String oem,
    @HiveField(2) @JsonKey(name: 'AppKey') required String appKey,
    @HiveField(3) @JsonKey(name: 'ExpireTime') required String expireTime,
    @HiveField(0) @JsonKey(name: 'AccessToken') String? accessToken,
  }) = _OEMAccount;

  factory OEMAccount.fromJson(Map<String, dynamic> json) =>
      _$OEMAccountFromJson(json);
}
