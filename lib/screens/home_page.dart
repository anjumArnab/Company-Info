import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rest_api_dio/services/api_call.dart';
import 'package:rest_api_dio/services/api_constants.dart';
import 'package:rest_api_dio/services/api_response.dart';
import 'create_information.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _futureCompanies;

  @override
  void initState() {
    super.initState();
    _futureCompanies = fetchCompanies();
  }

  Future<List<dynamic>> fetchCompanies() async {
    try {
      final response = await ApiCall.makeApiCall(
        ApiConstants.GET_INFO, // API path
        Method.GET,            // HTTP Method
        _ObjectApiResponse(),  // Actual response handler
        ApiName.GET_INFO,      // API name
      );

      // Log the raw response for debugging purposes
      log("Raw API Response: $response");

      // Check if the response is null or empty
      if (response == null || response.isEmpty) {
        throw Exception("No data found in the response");
      }

      // Check if the response is a List or contains a 'data' key
      if (response is List) {
        return response; // Direct list response
      } else if (response is Map && response.containsKey('data')) {
        return response['data'] as List; // If the response contains 'data'
      } else {
        // Log and throw an error for an unexpected response format
        log("Unexpected API response format: $response");
        throw Exception("Invalid response format");
      }
    } catch (error) {
      log("Error fetching companies: $error");
      return [];
    }
  }

  Future<void> deleteCompany(int companyId) async {
    try {
      // Construct the DELETE API path using the company ID
      String deleteApiPath = "${ApiConstants.BASE_URL}/$companyId";

      // Make the DELETE API request
      final dio = Dio();
      final response = await dio.delete(deleteApiPath);

      if (response.statusCode == 200) {
        log("Company deleted successfully");
      } else {
        log("Failed to delete company: ${response.statusMessage}");
      }
    } catch (error) {
      log("Error deleting company: $error");
    }
  }

  void handlePopupMenuSelection(String value, int companyId) {
    switch (value) {
      case 'Edit':
        // Navigate to edit page (not implemented here)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Edit functionality not yet implemented")),
        );
        break;
      case 'Delete':
        deleteCompany(companyId);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Company List")),
      body: FutureBuilder<List<dynamic>>(
        future: _futureCompanies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No companies found"));
          } else {
            final companies = snapshot.data!;
            return ListView.builder(
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
                return ListTile(
                  title: Text(company['company_name']),
                  subtitle: Text(company['company_address']),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) => handlePopupMenuSelection(value, company['id']),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'Delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateInformation(
                name: "",
                address: "",
                phone: "",
                logo: "",
                isEditing: false,
              ),
            ),
          );
          if (result == true) {
            setState(() {
              _futureCompanies = fetchCompanies();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ObjectApiResponse implements ApiResponse {
  @override
  void onResponse(dynamic response, ApiName apiName) {
    // Handle the response here by checking the API name and processing it accordingly.
    if (apiName == ApiName.GET_INFO) {
      // Perform additional processing or logging here if needed
      log("Response for GET_INFO: $response");
    }
  }

  @override
  void onError(dynamic errorMsg, ApiName apiName) {
    // Handle any errors that may occur during the API call
    log("Error occurred: $errorMsg");
  }
}
