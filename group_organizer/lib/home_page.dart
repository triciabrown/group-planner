// home_page.dart
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_organizer/app_state.dart'; 
import 'package:group_organizer/create_group_page.dart';
import 'package:badges/badges.dart' as badges;

class HomePage extends StatefulWidget { 
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  User? user; // current Firebase user
  int pendingInvitesCount = 0; 

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser; // get the current logged-in user
    _listenForInvites(); // Listen for pending invites
  }

  // Listen for pending invites
  void _listenForInvites() {
    if (user == null) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        var userData = snapshot.data() as Map<String, dynamic>;
        List<dynamic>? pendingInvites = userData['pendingInvitations'] ?? [];
        
        // Update pendingInvitesCount based on new invites
        if (pendingInvites != null){
          setState(() {
            pendingInvitesCount = pendingInvites.length;
          });
        }
      }
    });
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
          // Notification Icon
          IconButton(
            icon: badges.Badge(
              badgeContent: Text(
                '$pendingInvitesCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.red,
                elevation: 0,
              ),
              showBadge: pendingInvitesCount > 0,
              child: const Icon(Icons.notifications),
            ),
            onPressed: _showInvitesDialog, // Show dialog with pending invites
          ),
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
                return const Center(child: Text('No groups available.'));
              }
              
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
    );
  }

  // Show a dialog with pending invites
  void _showInvitesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pending Group Invites"),
          content: pendingInvitesCount > 0
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                  width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                  child: ListView.builder(
                    itemCount: pendingInvitesCount,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text("Invite $index"),
                        subtitle: const Text("You have been invited to join this group."),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                //_acceptInvite(String userId, String groupId)
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                // Decline invite logic
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              : const Text("No new invites."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }


  Future<void> _acceptInvite(String userId, String groupId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      // Update the user's document to add the group ID to their 'groups' list
      await userRef.update({
        'groups': FieldValue.arrayUnion([FirebaseFirestore.instance.collection('groups').doc(groupId)])
      });

      // Optional: Remove the pending invite if it's stored in Firestore
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('pending_invites')
          .where('userId', isEqualTo: userId)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();  // Remove the invite document after it’s accepted
        }
      });

      // Feedback to the user (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group added to your list.')),
      );
    } catch (e) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept invite: $e')),
      );
    }
  }
}
