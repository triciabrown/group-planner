// group_details_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupDetailsPage extends StatelessWidget {
  final String groupId;

  const GroupDetailsPage({Key? key, required this.groupId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('groups').doc(groupId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Error loading group details.'));
          }

          var groupData = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Group Name: ${groupData['name']}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Description: ${groupData['description'] ?? "No description available"}',
                ),
                
                const SizedBox(height: 24),  // Spacing before the button

                // Invite Button
                ElevatedButton.icon(
                  onPressed: () {
                    _inviteNewMember(context);
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Invite New Member'),
                ),

                // Additional group details could go here
                // e.g., list of members, group rules, etc.
              ],
            ),
          );
        },
      ),
    );
  }

  // Function to handle inviting a new member with input field for phone/email
  void _inviteNewMember(BuildContext context) {
    final TextEditingController contactController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite New Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the email address of the person you want to invite:'),
            const SizedBox(height: 10),
            TextField(
              controller: contactController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress, 
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final contact = contactController.text.trim();
              if (contact.isNotEmpty) {
                _sendInvite(context, contact);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid email address.')),
                );
              }
            },
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }

// Method to send an invitation
  Future<void> _sendInvite(BuildContext context, String email) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    
    try {
      //Check if the user already exists
      final querySnapshot = await usersCollection.where('email', isEqualTo: email).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        //If user exists, show a message that they are already a member
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User with this email is already registered.')),
        );
        return;
      }

      // Step 2: If user does not exist, send invite email
      await _sendEmailInvite(email);

      // Step 3: Optionally, save the invite status in Firestore (e.g., under 'pending_invites' collection)
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('pending_invites')
          .add({'email': email, 'invited_at': Timestamp.now()});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invite sent to $email')),
      );

    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send invite: $e')),
      );
    }
  }

  Future<void> _sendEmailInvite(String email) async {
    // TODO: implement logic for sending email, configure firebase functions backend
    
    //final callable = FirebaseFunctions.instance.httpsCallable('sendInviteEmail');
    //await callable.call({'email': email});
    
    // Temporary print statement as a placeholder
    print("Sending invite email to $email");
  }
}
