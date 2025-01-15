import 'package:flutter/material.dart';

class CreateInformation extends StatefulWidget {
  final int? id;
  final String name;
  final String address;
  final String phone;
  final String logo; // This is a URL for the logo
  final bool isEditing;
  const CreateInformation({
    super.key,
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.logo,
    this.isEditing = false,
  });

  @override
  State<CreateInformation> createState() => _CreateInformationState();
}

class _CreateInformationState extends State<CreateInformation> {
  final _formKey = GlobalKey<FormState>();
  /*
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  */
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _phoneController = TextEditingController();
  late TextEditingController _addressController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _addressController = TextEditingController(text: widget.address);
    _phoneController = TextEditingController(text: widget.phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.isEditing
              ? "Update Company Information"
              : "Add Company Information",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the phone number';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Check if the form is being edited or newly created
                    if (widget.isEditing) {
                      // Handle form update
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Information Updated!')),
                      );
                    } else {
                      // Handle new form submission
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Information Added!')),
                      );
                    }
                  }
                },
                child: Text(
                  widget.isEditing ? "Update" : "Add",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
