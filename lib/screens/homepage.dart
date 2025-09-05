import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _futureCompanies = fetchCompanies();
  }

  // Fetch companies from API with better error handling
  Future<List<Company>> fetchCompanies() async {
    try {
      final response = await ApiCall.makeApiCall(
        ApiConstants.GET_INFO,
        Method.GET,
        _ObjectApiResponse(),
        ApiName.GET_INFO,
      );

      log("Raw API Response: $response");

      if (response == null) {
        throw Exception("No response received from server");
      }

      if (response is List) {
        if (response.isEmpty) {
          return []; // Return empty list instead of throwing exception
        }
        return response.map((e) => Company.fromJson(e)).toList();
      } else if (response is Map && response.containsKey('data')) {
        final dataList = response['data'] as List;
        if (dataList.isEmpty) {
          return [];
        }
        return dataList.map((e) => Company.fromJson(e)).toList();
      } else {
        log("Unexpected API response format: $response");
        throw Exception("Invalid response format from server");
      }
    } catch (error) {
      log("Error fetching companies: $error");
      rethrow; // Re-throw to let FutureBuilder handle the error
    }
  }

  // Delete company with improved error handling and user feedback
  Future<void> deleteCompany(int companyId, String companyName) async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "$companyName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      // Construct the correct delete API path
      String deleteApiPath = "${ApiConstants.GET_INFO}/$companyId";
      final dio = Dio();
      final response = await dio.delete(deleteApiPath);

      if (response.statusCode == 200 || response.statusCode == 204) {
        log("Company deleted successfully");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$companyName deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh the list
          setState(() {
            _futureCompanies = fetchCompanies();
          });
        }
      } else {
        throw Exception("Failed to delete: ${response.statusMessage}");
      }
    } catch (error) {
      log("Error deleting company: $error");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete $companyName: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
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
        deleteCompany(company.id, company.companyName);
        break;
    }
  }

  // Pull to refresh functionality
  Future<void> _refreshCompanies() async {
    setState(() {
      _futureCompanies = fetchCompanies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Company List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCompanies,
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshCompanies,
            child: FutureBuilder<List<Company>>(
              future: _futureCompanies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                          "Error loading companies",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${snapshot.error}",
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshCompanies,
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
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text("Add your first company to get started"),
                      ],
                    ),
                  );
                } else {
                  final companies = snapshot.data!;
                  return ListView.builder(
                    itemCount: companies.length,
                    itemBuilder: (context, index) {
                      final company = companies[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: company.logo.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    company.logo,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.business),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.business),
                                ),
                          title: Text(
                            company.companyName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(company.companyAddress),
                              if (company.companyNumber.isNotEmpty)
                                Text(
                                  company.companyNumber,
                                  style: TextStyle(color: Colors.blue[700]),
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
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'Delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete,
                                        size: 18, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          if (_isDeleting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
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
