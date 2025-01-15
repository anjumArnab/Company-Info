import 'package:flutter/material.dart';

class CreateInformation extends StatelessWidget {
  final String name;
  final String address;
  final String phone;
  final String logo;
  final bool isEditing;

  const CreateInformation({
    Key? key,
    required this.name,
    required this.address,
    required this.phone,
    required this.logo,
    required this.isEditing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create/Edit Company")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: "Company Name"),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Address"),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Phone"),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Logo URL"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true); // Simulating a successful create/edit
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
