// group_details_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:group_organizer/todo_list_page.dart'; 

class GroupDetailsPage extends StatefulWidget {
  final String groupId;

  const GroupDetailsPage({Key? key, required this.groupId}) : super(key: key);

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
late final scaffoldMessenger = ScaffoldMessenger.of(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Details'),
        actions: [
          // Add IconButton for navigation to ToDoListPage
          IconButton(
            icon: const Icon(Icons.check_box), // Checkbox icon for the to-do list
            onPressed: () {
              // Navigate to ToDoListPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ToDoListPage(groupId: widget.groupId),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Error loading group details.'));
          }

          var groupData = snapshot.data!.data() as Map<String, dynamic>;
          //var members = groupData['members'];
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
                //const SizedBox(height: 16),
                // const Text(
                //   'Members',
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                // Expanded(
                //   child: ListView.builder(
                //     itemCount: members.length,
                //     itemBuilder: (context, index) {
                //       final member = members[index];
                //       return ListTile(
                //         leading: Icon(Icons.person),
                //         title: Text(member),
                //       );
                //     },
                //   ),
                // ),
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

  // Function to handle inviting a new member with input field for email
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
                scaffoldMessenger.showSnackBar(
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
      // Check if the user already exists in the users collection
      final querySnapshot = await usersCollection.where('email', isEqualTo: email).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        // User exists in Firestore, so add the invite to their record
        final userDoc = querySnapshot.docs.first.reference;

        String userid = FirebaseAuth.instance.currentUser!.uid;

        final currentUser = await FirebaseFirestore.instance.collection('users').doc(userid).get();

        final currentUserName = currentUser.data()?['displayName'] as String;
        
        // Create an invitation object to be stored
        final invitation = {
          'groupId': widget.groupId,
          'invitedBy' : currentUserName,
          'groupName': await _fetchGroupName(),  // Fetch the group's name (helper function below)
          'invitedAt': Timestamp.now(),
        };

        // Use Firestore's arrayUnion to add the invitation to the user's record
        await userDoc.update({
          'pendingInvitations': FieldValue.arrayUnion([invitation]),
        });
        if(mounted){
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Invitation sent to user\'s account.')),
          );
        }
      } else {
        // If the user does not exist, send an invite email
        //TODO future implementation since I dont have actual company emails set up
        //await _sendEmailInvite(email);
        if (mounted){
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('$email is not currently a user of FestieBestie')),
          );
        }
      }
    } catch (e) {
      // Error handling
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send invite: $e')),
        );
      }
    }
  }

  // Future<void> _sendEmailInvite(String email) async {
  //   // TODO: implement logic for sending email, configure firebase functions backend
    
  //   //final callable = FirebaseFunctions.instance.httpsCallable('sendInviteEmail');
  //   //await callable.call({'email': email});
    
  //   // Temporary print statement as a placeholder
  //   print("Sending invite email to $email");
  // }

  // Helper function to fetch group name by groupId
  Future<String> _fetchGroupName() async {
    final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();
    return groupDoc.exists && groupDoc.data() != null ? groupDoc['name'] as String : 'Unknown Group';
  }
}