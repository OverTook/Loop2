import 'package:json_annotation/json_annotation.dart';

part 'response_model.g.dart';

@JsonSerializable()
class LicenseResponse {
  bool success;
  String msg;

  LicenseResponse({
    required this.success,
    required this.msg,
  });

  factory LicenseResponse.fromJson(Map<String, dynamic> json) => _$LicenseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LicenseResponseToJson(this);
}