import 'dart:developer';
import 'package:flutter/material.dart';
import '../widgets/company_logo.dart';
import '../services/api_call.dart';
import '../services/api_constants.dart';
import '../services/api_response.dart';
import 'create_company.dart';
import '../model/company.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Future<List<Company>> _futureCompanies;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _futureCompanies = fetchCompanies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch companies from API
  Future<List<Company>> fetchCompanies() async {
    try {
      final response = await ApiCall.makeApiCall(
        ApiConstants.GET_COMPANIES,
        Method.GET,
        _ObjectApiResponse(),
        ApiName.GET_COMPANIES,
      );

      log("Raw API Response: $response");

      if (response == null) {
        throw Exception("No data found in the response");
      }

      if (response is List) {
        return response.map((e) => Company.fromJson(e)).toList();
      } else {
        log("Unexpected API response format: $response");
        throw Exception("Invalid response format");
      }
    } catch (error) {
      log("Error fetching companies: $error");
      return [];
    }
  }

  // Search companies by name
  Future<List<Company>> searchCompanies(String companyName) async {
    if (companyName.trim().isEmpty) {
      return fetchCompanies();
    }

    try {
      final response = await ApiCall.makeApiCall(
        ApiConstants.searchCompany(companyName),
        Method.GET,
        _ObjectApiResponse(),
        ApiName.SEARCH_COMPANY,
      );

      log("Search API Response: $response");

      if (response == null) {
        return [];
      }

      if (response is List) {
        return response.map((e) => Company.fromJson(e)).toList();
      } else {
        log("Unexpected search response format: $response");
        return [];
      }
    } catch (error) {
      log("Error searching companies: $error");
      return [];
    }
  }

  // Delete company and refresh list
  Future<void> deleteCompany(int companyId) async {
    try {
      final response = await ApiCall.makeApiCall(
        ApiConstants.deleteCompany(companyId),
        Method.DELETE,
        _ObjectApiResponse(),
        ApiName.DELETE_COMPANY,
      );

      if (response != null) {
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
        _refreshCompanies();
      } else {
        log("Failed to delete company");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to delete company"),
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

  // Refresh companies list
  void _refreshCompanies() {
    if (_isSearching && _searchController.text.trim().isNotEmpty) {
      setState(() {
        _futureCompanies = searchCompanies(_searchController.text.trim());
      });
    } else {
      setState(() {
        _futureCompanies = fetchCompanies();
      });
    }
  }

  // Handle search
  void _handleSearch(String query) {
    setState(() {
      _isSearching = query.trim().isNotEmpty;
      _futureCompanies = searchCompanies(query);
    });
  }

  // Clear search
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _futureCompanies = fetchCompanies();
    });
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
            builder: (context) => CreateCompany(
              company: company,
              isEditing: true,
            ),
          ),
        ).then((result) {
          if (result == true) {
            _refreshCompanies();
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _handleSearch,
                    decoration: InputDecoration(
                      hintText: "Search companies...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateCompany(
                    company: null,
                    isEditing: false,
                  ),
                ),
              );
              if (result == true) {
                _refreshCompanies();
              }
            },
            tooltip: "Create Company",
          ),
        ],
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
                    _isSearching
                        ? "No companies found for your search"
                        : "No companies found",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSearching
                        ? "Try a different search term"
                        : "Tap the + button to add a company",
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
                _refreshCompanies();
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
