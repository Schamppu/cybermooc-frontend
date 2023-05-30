import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/company_contact.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(FrontendApp());
}

/// Uri for the local host server.
final uri = "http://127.0.0.1:8080/";

/// List of contact objects.
List<CompanyContact> contacts = [];

class FrontendApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Frontend',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FrontendScreen(),
    );
  }
}

class FrontendScreen extends StatefulWidget {
  @override
  _FrontendScreenState createState() => _FrontendScreenState();
}

class _FrontendScreenState extends State<FrontendScreen> {
  final TextEditingController _firstNameEditingController = TextEditingController();
  final TextEditingController _lastNameEditingController = TextEditingController();
  final TextEditingController _phoneNumberEditingController = TextEditingController();

  Future<void> fetchTasks(String user, String pass) async {
    final response = await http.get(
      Uri.parse(uri),
      headers: {'Authorization': 'Basic ' + '$user:$pass'},
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      contacts.clear();
      print(jsonData);
      setState(() {
        List jsonMap = List.from(jsonData);
        for (Map row in jsonMap) {
          contacts.add(CompanyContact(row['id'], row['companyName'], row['firstName'], row['lastName'], row['phone']));
        }
      });
    } else {
      print('Failed to fetch tasks: ${response.statusCode}');
    }
  }

  Future<void> addContact() async {
    final firstName = _firstNameEditingController.text;
    final lastName = _lastNameEditingController.text;
    final phoneNumber = _phoneNumberEditingController.text;
    final response = await http.post(
      Uri.parse(uri),
      body: json.encode({'firstName': firstName, 'lastName': lastName, 'phone': phoneNumber}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 201) {
      print('Post success!');
    } else {
      print('Failed to add contact: ${response.statusCode}, body: ${response.body}');
    }
  }

  Future<void> removeContact(String id) async {
    print('delete...');
    final response = await http.post(
      Uri.parse(uri),
      body: json.encode({'delete': true, 'id': id}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 202) {
      print('Delete success!');
      // Delete locally
      setState(() {
        contacts.removeWhere((contact) => contact.id == id);
      });
    } else {
      print('Failed to add contact: ${response.statusCode}, body: ${response.body}');
    }
  }

  Future<void> getInformation(BuildContext context) async {
    final TextEditingController _username = TextEditingController();
    final TextEditingController _password = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _username,
                decoration: const InputDecoration(
                  labelText: 'Admin username',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _password,
                decoration: const InputDecoration(
                  labelText: 'Admin password',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton(
                child: const Text('Get All People'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      fetchTasks(_username.text, _password.text);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frontend App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _firstNameEditingController,
              decoration: const InputDecoration(
                labelText: 'First name',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _lastNameEditingController,
              decoration: const InputDecoration(
                labelText: 'Last name',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _phoneNumberEditingController,
              decoration: const InputDecoration(
                labelText: 'Phone number',
              ),
            ),
          ),
          FilledButton(
            child: const Text('Add Contact Information'),
            onPressed: addContact,
          ),
          const SizedBox(
            height: 15,
          ),
          FilledButton(
            child: const Text('Get All People'),
            onPressed: () {
              getInformation(context);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(contacts[index].phone),
                  subtitle: Text(contacts[index].firstName + ' ' + contacts[index].lastName),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => removeContact(contacts[index].id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
