import 'dart:developer';
import 'package:flutter/material.dart';
import '../widgets/company_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../services/api_call.dart';
import '../services/api_constants.dart';
import '../services/api_response.dart';
import '../model/company.dart';

class CreateCompany extends StatefulWidget {
  final Company? company;
  final bool isEditing;

  const CreateCompany({
    super.key,
    required this.company,
    required this.isEditing,
  });

  @override
  State<CreateCompany> createState() => _CreateCompanyState();
}

class _CreateCompanyState extends State<CreateCompany> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _logoController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.company != null) {
      _nameController.text = widget.company!.companyName;
      _addressController.text = widget.company!.companyAddress;
      _phoneController.text = widget.company!.companyNumber;
      _logoController.text = widget.company!.logo;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  // Create new company
  Future<bool> createCompany() async {
    try {
      final companyData = {
        'company_name': _nameController.text.trim(),
        'company_address': _addressController.text.trim(),
        'company_number': _phoneController.text.trim(),
        'logo': _logoController.text.trim(),
      };

      final response = await ApiCall.makeApiCall(
        ApiConstants.CREATE_COMPANY,
        Method.POST,
        _CompanyApiResponse(),
        ApiName.CREATE_COMPANY,
        data: companyData,
      );

      if (response != null) {
        log("Company created successfully: $response");
        return true;
      } else {
        log("Failed to create company");
        return false;
      }
    } catch (error) {
      log("Error creating company: $error");
      return false;
    }
  }

  // Update existing company
  Future<bool> updateCompany() async {
    try {
      final companyData = {
        'company_name': _nameController.text.trim(),
        'company_address': _addressController.text.trim(),
        'company_number': _phoneController.text.trim(),
        'logo': _logoController.text.trim(),
      };

      final response = await ApiCall.makeApiCall(
        ApiConstants.updateCompany(widget.company!.id),
        Method.PUT,
        _CompanyApiResponse(),
        ApiName.UPDATE_COMPANY,
        data: companyData,
      );

      if (response != null) {
        log("Company updated successfully: $response");
        return true;
      } else {
        log("Failed to update company");
        return false;
      }
    } catch (error) {
      log("Error updating company: $error");
      return false;
    }
  }

  // Validate form fields
  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      _showErrorMessage("Company name is required");
      return false;
    }
    if (_addressController.text.trim().isEmpty) {
      _showErrorMessage("Company address is required");
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showErrorMessage("Phone number is required");
      return false;
    }
    return true;
  }

  // Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Handle save/update button press
  Future<void> _handleSaveUpdate() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success;
    if (widget.isEditing) {
      success = await updateCompany();
    } else {
      success = await createCompany();
    }

    setState(() {
      _isLoading = false;
    });

    if (success) {
      _showSuccessMessage(
        widget.isEditing
            ? "Company updated successfully"
            : "Company created successfully",
      );
      // Return to previous screen with success result
      Navigator.pop(context, true);
    } else {
      _showErrorMessage(
        widget.isEditing
            ? "Failed to update company"
            : "Failed to create company",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text(widget.isEditing ? "Edit Company" : "Create Company"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_logoController.text.isNotEmpty)
                Center(
                  child: CompanyLogo(logoUrl: _logoController.text),
                ),
              const SizedBox(height: 25),
              CustomTextField(
                label: "Company Name",
                icon: Icons.business,
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Company name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              CustomTextField(
                label: "Address",
                icon: Icons.location_on,
                controller: _addressController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              CustomTextField(
                label: "Phone",
                icon: Icons.phone,
                inputType: TextInputType.phone,
                controller: _phoneController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              CustomTextField(
                label: "Logo URL",
                icon: Icons.image,
                controller: _logoController,
                onChanged: (value) {
                  // Rebuild to show logo preview
                  setState(() {});
                },
              ),
              const SizedBox(height: 30),
              PrimaryButton(
                text: widget.isEditing ? "Update" : "Save",
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _handleSaveUpdate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// API response handler for company operations
class _CompanyApiResponse implements ApiResponse {
  @override
  void onResponse(dynamic response, ApiName apiName) {
    log("Company API Response for $apiName: $response");
  }

  @override
  void onError(dynamic errorMsg, ApiName apiName) {
    log("Company API Error for $apiName: $errorMsg");
  }
}
