import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class CreateInformation extends StatelessWidget {
  final String name;
  final String address;
  final String phone;
  final String logo;
  final bool isEditing;

  const CreateInformation({
    super.key,
    required this.name,
    required this.address,
    required this.phone,
    required this.logo,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Company" : "Create Company"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (logo.isNotEmpty)
              Center(
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: NetworkImage(logo),
                ),
              ),
            const SizedBox(height: 25),
            CustomTextField(
              label: "Company Name",
              icon: Icons.business,
              initialValue: name,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: "Address",
              icon: Icons.location_on,
              initialValue: address,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: "Phone",
              icon: Icons.phone,
              inputType: TextInputType.phone,
              initialValue: phone,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: "Logo URL",
              icon: Icons.image,
              initialValue: logo,
            ),
            const SizedBox(height: 30),
            PrimaryButton(
              text: isEditing ? "Update" : "Save",
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    );
  }
}
