import 'package:dio/dio.dart';
import 'package:rest_api_dio/services/api_constants.dart';
import 'package:rest_api_dio/services/api_response.dart';

class ApiCall {
  static Future<dynamic> makeApiCall(
    String apiPath,
    Method method,
    ApiResponse apiResponseListener,
    ApiName apiName,
  ) async {
    final dio = Dio();
    try {
      Response response;

      switch (method) {
        case Method.GET:
          response = await dio.get(apiPath);
          break;
        case Method.POST:
          response = await dio.post(apiPath);
          break;
        case Method.PUT:
          response = await dio.put(apiPath);
          break;
        case Method.DELETE:
          response = await dio.delete(apiPath);
          break;
        default:
          throw Exception("Unsupported HTTP method");
      }

      apiResponseListener.onResponse(response.data, apiName);
      return response.data;
    } on DioException catch (e) {
      apiResponseListener.onError(e.message, apiName);
      return null;
    }
  }
}