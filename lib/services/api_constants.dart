// ignore_for_file: constant_identifier_names, non_constant_identifier_names

class ApiConstants {
  static const String BASE_URL = "https://retoolapi.dev/QCIfDy/";
  static const String ENDPOINT = "company";
  static String get GET_COMPANIES => BASE_URL + ENDPOINT;
  static String getCompanyById(int id) => "$BASE_URL$ENDPOINT/$id";
  static String get CREATE_COMPANY => BASE_URL + ENDPOINT;
  static String updateCompany(int id) => "$BASE_URL$ENDPOINT/$id";
  static String deleteCompany(int id) => "$BASE_URL$ENDPOINT/$id";
  static String searchCompany(String companyName) =>
      "$BASE_URL$ENDPOINT?company_name=$companyName";
  static String getPaginatedCompanies(int page, int limit) =>
      "$BASE_URL$ENDPOINT?_page=$page&_limit=$limit";
}

enum Method { GET, POST, PUT, PATCH, DELETE }

enum ApiName {
  GET_COMPANIES,
  GET_COMPANY_BY_ID,
  CREATE_COMPANY,
  UPDATE_COMPANY,
  DELETE_COMPANY,
  SEARCH_COMPANY
}
