import 'package:dio/dio.dart';
import 'package:rest_api_dio/services/api_constants.dart';
import 'package:rest_api_dio/services/api_response.dart';

class ApiCall {
  static Future<dynamic> makeApiCall(
    String apiPath,
    Method method,
    ApiResponse apiResponseListener,
    ApiName apiName, {
    Map<String, dynamic>? data,
  }) async {
    final dio = Dio();
    try {
      Response response;

      switch (method) {
        case Method.GET:
          response = await dio.get(apiPath);
          break;
        case Method.POST:
          response = await dio.post(apiPath, data: data);
          break;
        case Method.PUT:
          response = await dio.put(apiPath, data: data);
          break;
        case Method.PATCH:
          response = await dio.patch(apiPath, data: data);
          break;
        case Method.DELETE:
          response = await dio.delete(apiPath);
          break;
      }

      apiResponseListener.onResponse(response.data, apiName);
      return response.data;
    } on DioException catch (e) {
      apiResponseListener.onError(e.message, apiName);
      return null;
    }
  }
}
