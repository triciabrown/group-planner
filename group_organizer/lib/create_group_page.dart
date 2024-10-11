// home_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({Key? key}) : super(key: key);

  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final CollectionReference groupsCollection = FirebaseFirestore.instance.collection('groups');
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final groupName = _groupNameController.text;
      final groupDescription = _groupDescriptionController.text;

      createNewGroup(groupName, groupDescription);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group "$groupName" created successfully!')),
      );

      // Navigate back or to another page
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _groupNameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _groupDescriptionController,
                decoration: const InputDecoration(labelText: 'Group Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Create Group'),
              ),
            ],
          ),
        ),
      ),
    );
  }

Future<void> createNewGroup(String groupName, String groupDescription) async {
  try {
    String userid = FirebaseAuth.instance.currentUser!.uid;
    final DocumentReference userDoc = usersCollection.doc(userid);
    DocumentReference newGroup = await groupsCollection.add({
      'name': groupName,
      'description': groupDescription,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': userid,  // User ID of the creator
      'members': [userid],  // Add the creator to the members list
    });

    await userDoc.update({
      'groups' : FieldValue.arrayUnion([newGroup]),
    });
  } catch (e) {
    print('Error adding group: $e');
  }
}



}
