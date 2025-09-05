import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../widgets/company_logo.dart';
import '../services/api_call.dart';
import '../services/api_constants.dart';
import '../services/api_response.dart';
import 'create_information.dart';
import '../model/company.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Future<List<Company>> _futureCompanies;

  @override
  void initState() {
    super.initState();
    _futureCompanies = fetchCompanies();
  }

  // Fetch companies from API
  Future<List<Company>> fetchCompanies() async {
    try {
      final response = await ApiCall.makeApiCall(
        ApiConstants.GET_INFO,
        Method.GET,
        _ObjectApiResponse(),
        ApiName.GET_INFO,
      );

      log("Raw API Response: $response");

      if (response == null || (response is List && response.isEmpty)) {
        throw Exception("No data found in the response");
      }

      if (response is List) {
        return response.map((e) => Company.fromJson(e)).toList();
      } else if (response is Map && response.containsKey('data')) {
        return (response['data'] as List)
            .map((e) => Company.fromJson(e))
            .toList();
      } else {
        log("Unexpected API response format: $response");
        throw Exception("Invalid response format");
      }
    } catch (error) {
      log("Error fetching companies: $error");
      return [];
    }
  }

  // Delete company and refresh list
  Future<void> deleteCompany(int companyId) async {
    try {
      String deleteApiPath = "${ApiConstants.BASE_URL}$companyId";
      final dio = Dio();
      final response = await dio.delete(deleteApiPath);

      if (response.statusCode == 200 || response.statusCode == 204) {
        log("Company deleted successfully");
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Company deleted successfully"),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Refresh the list
        setState(() {
          _futureCompanies = fetchCompanies();
        });
      } else {
        log("Failed to delete company: ${response.statusMessage}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text("Failed to delete company: ${response.statusMessage}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      log("Error deleting company: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting company: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show delete confirmation dialog
  Future<void> showDeleteConfirmation(int companyId, String companyName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "$companyName"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                deleteCompany(companyId);
              },
            ),
          ],
        );
      },
    );
  }

  // Handle popup menu actions
  void handlePopupMenuSelection(String value, Company company) {
    switch (value) {
      case 'Edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateInformation(
              name: company.companyName,
              address: company.companyAddress,
              phone: company.companyNumber,
              logo: company.logo,
              isEditing: true,
            ),
          ),
        ).then((result) {
          if (result == true) {
            setState(() {
              _futureCompanies = fetchCompanies();
            });
          }
        });
        break;
      case 'Delete':
        showDeleteConfirmation(company.id, company.companyName);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Company List"),
      ),
      body: FutureBuilder<List<Company>>(
        future: _futureCompanies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading companies..."),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[600]),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _futureCompanies = fetchCompanies();
                      });
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No companies found",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap the + button to add a company",
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          } else {
            final companies = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _futureCompanies = fetchCompanies();
                });
                await _futureCompanies;
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: companies.length,
                itemBuilder: (context, index) {
                  final company = companies[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CompanyLogo(logoUrl: company.logo),
                    title: Text(
                      company.companyName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          company.companyAddress,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          company.companyNumber,
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) =>
                          handlePopupMenuSelection(value, company),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'Edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'Delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
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

// Default API response handler
class _ObjectApiResponse implements ApiResponse {
  @override
  void onResponse(dynamic response, ApiName apiName) {
    log("Response for $apiName: $response");
  }

  @override
  void onError(dynamic errorMsg, ApiName apiName) {
    log("Error occurred for $apiName: $errorMsg");
  }
}
