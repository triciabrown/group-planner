// home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
              context.push('/create-group'); // TODO: implement create-group route
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to the profile page
              context.push('/profile');
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
