// home_page.dart
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_organizer/create_group_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  body: const CreateGroupPage()),
                ) 
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to the profile page
              //context.pushNamed('profile');
              //need to implement app bar on profile screen (or scaffold)
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: const Text('Profile'),
                  ),
                  body: const ProfileScreen()),
                ) 
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'No groups available. Start by creating one!',
          style: TextStyle(fontSize: 16),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // You can also add another way to create groups using the FAB
          context.push('/create-group'); // Replace with actual route
        },
        tooltip: 'Create Group',
        child: const Icon(Icons.add),
      ),
    );
  }
}
