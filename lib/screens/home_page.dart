import 'package:flutter/material.dart';
import 'package:rest_api_dio/screens/create_information.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int count = 30;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Company Information"),
      ),
      body: ListView.builder(
        itemCount: count,
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: Image.network(
                "https://logo.clearbit.com/google.ru",
                width: 60.0,
                height: 60.0,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              "Oracle",
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4.0),
                Text(
                  "(555) 745-1341",
                  style: const TextStyle(fontSize: 14.0),
                ),
                const SizedBox(height: 4.0),
                Text(
                  "Eden Prairie, Minnesota, United States",
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
                SizedBox(height:15),
                Divider(endIndent: 90,indent:80),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Edit') {
                  // edit logic
                  _updateInformation();
                } else if (value == 'Delete') {
                  // delete logic
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem<String>(
                  value: 'Delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: ClipOval(
        child: FloatingActionButton(
          onPressed: (){
            _createInformationPage();
          },
          child:const Icon(Icons.add),),
      ),
    );
  }
 void  _createInformationPage(){
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateInformation(name:"",address: "",phone:"", logo:"", isEditing: false,),
      ),
    );
  }

  void _updateInformation(){
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateInformation(
          name: "oracle"??"",
          address: "Eden Prairie, Minnesota, United States"??"",
          phone: "(555) 745-1341"??"",
          logo: "https://logo.clearbit.com/google.ru",
          isEditing: true
        ),
      ),
    );

  }
}
