class ApiConstants {
  static const String BASE_URL = "https://retoolapi.dev/0PWEu7/";
  static const String ENDPOINT = "data";
  static String get GET_INFO => BASE_URL + ENDPOINT;
}

enum Method { GET, POST, PUT, DELETE }

enum ApiName { GET_INFO, UPDATE }
