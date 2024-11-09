// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LicenseResponse _$LicenseResponseFromJson(Map<String, dynamic> json) =>
    LicenseResponse(
      success: json['success'] as bool,
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$LicenseResponseToJson(LicenseResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'msg': instance.msg,
    };
