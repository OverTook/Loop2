import 'package:dio/dio.dart';
import 'package:loop/network/request_model.dart';
import 'package:loop/network/response_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'client.g.dart';

@RestApi(baseUrl: 'http://csgpu.kku.ac.kr:5127')
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @POST('/license_add')
  Future<LicenseResponse> addLicense(@Body() LicenseRequest request);
}


class FirebaseTokenInterceptor extends Interceptor {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final user = _auth.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      options.headers["Authorization"] = "Bearer $token";
    }
    return super.onRequest(options, handler);
  }
}
