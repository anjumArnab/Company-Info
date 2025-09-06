import 'package:rest_api_dio/services/api_constants.dart';

abstract class ApiResponse {
  void onResponse(dynamic response, ApiName apiName);
  void onError(dynamic errorMsg, ApiName apiName);
}
