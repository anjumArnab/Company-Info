import 'package:rest_api_dio/services/api_constants.dart';

abstract class ApiResponse {
  void onResponse(dynamic response, ApiName apiName);
  void onError(dynamic errorMsg, ApiName apiName);
}

class _ObjectApiResponse implements ApiResponse {
  @override
  void onResponse(dynamic response, ApiName apiName) {
    // Handle the response here if needed
    // (though we're returning it directly in fetchCompanies)
  }

  @override
  void onError(dynamic errorMsg, ApiName apiName) {
    print("API error: $errorMsg");
  }
}
