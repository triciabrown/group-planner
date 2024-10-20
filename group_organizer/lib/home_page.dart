// home_page.dart
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_organizer/app_state.dart'; 
import 'package:group_organizer/create_group_page.dart';

class HomePage extends StatefulWidget { 
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user; // current Firebase user

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser; // get the current logged-in user
  }

  @override
  Widget build(BuildContext context) {    
  if (user == null) { 
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Groups'),
        ),
        body: const Center(child: Text('No user is logged in.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Groups"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Create New Group'),
                    ),
                    body: const CreateGroupPage(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              context.pushNamed('profile');
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>( // listen to  changes from Firestore
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid) 
            .snapshots(), 
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading groups.')); 
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No groups available.')); 
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic>? groupRefs = userData['groups'];

          if (groupRefs == null || groupRefs.isEmpty) {
            return const Center(
              child: Text('No groups available. Start by creating one!'),
            );
          }

          return FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait(
              groupRefs.map((groupRef) => (groupRef as DocumentReference).get()), // Fetch each group document
            ),
            builder: (context, groupSnapshot) {
              if (groupSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator()); // Show a loading spinner while waiting for data
              }

              if (!groupSnapshot.hasData || groupSnapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No groups available.'), 
                );
              }

              // display a list of groups from the fetched group documents
              var groups = groupSnapshot.data!;
              return ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  var groupData = groups[index].data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(groupData['name'] ?? 'Unnamed Group'), //display group name
                    subtitle: Text('Group ID: ${groups[index].id}'), // display group ID
                    onTap: () {
                      context.push('/group/${groups[index].id}');
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/create-group'); // Navigate to group creation page
        },
        tooltip: 'Create Group',
        child: const Icon(Icons.add),
      ),
    );
  }
}
