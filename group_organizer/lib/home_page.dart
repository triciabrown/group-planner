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
  List<Map<String,String>> pendingInvites = [];

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
        var invites = userData['pendingInvitations'] as List<dynamic>? ?? [];

        List<Map<String,String>> formattedInvites = invites.map((invite) {
          return {
            'groupName': invite['groupName']?.toString() ?? 'Unknown Group',
            'invitedBy': invite['invitedBy']?.toString() ?? 'Unknown User',
            'groupId': invite['groupId']?.toString() ?? '',
          };
        }).toList();
        
        // Update pendingInvitesCount based on new invites

        if (mounted){
          setState(() {
            pendingInvitesCount = formattedInvites.length;
            pendingInvites = formattedInvites;
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
            onPressed: () async {
              if (context.mounted) { 
                _showInvitesDialog(pendingInvites);
              }
            },
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
              return ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey.shade300, // Customizable divider color
                  thickness: 1, // Thin divider
                  indent: 16, // Left padding
                  endIndent: 16, // Right padding
                ),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  var groupData = groups[index].data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(
                      groupData['name'] ?? 'Unnamed Group', 
                      style: const TextStyle(
                        fontWeight: FontWeight.w600, // Slightly bolder
                        fontSize: 16, // Slightly larger
                      ),
                    ),
                    subtitle: groupData['description'] != null 
                      ? Text(
                          groupData['description'], 
                          maxLines: 1, // Limit to one line
                          overflow: TextOverflow.ellipsis, // Add ellipsis if too long
                        )
                      : null,
                    trailing: const Icon(Icons.chevron_right),
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
  void _showInvitesDialog(List<Map<String,String>> invites) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pending Group Invites"),
          content: invites.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                  width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                  child: ListView.builder(
                    itemCount: invites.length,
                    itemBuilder: (context, index) {
                      final invite = invites[index];
                  return ListTile(
                        title: Text(invite['groupName'] ?? "Unknown group"),
                        subtitle: Text('Invited by: ${invite['inviterName'] ?? 'Unknown User'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                _acceptInvite(invite['groupId']);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                _declineInvite(invite['groupId']);
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

  Future<List<Map<String, String>>> fetchPendingInvites() async {
    List<Map<String, String>> invites = [];

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return invites;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('pendingInvitations')
          .get();

      for (var doc in snapshot.docs) {
        invites.add({
          'groupName': doc['groupName'] ?? 'Unnamed Group',
          'invitedBy': doc['invitedBy'] ?? 'Unknown',
          'groupId': doc['groupId'] ?? 'Unknown'
        });
      }
    } catch (e) {
      print('Error fetching invites: $e');
    }

    return invites;
  }


  Future<void> _acceptInvite(String? groupId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
    final groupRef = FirebaseFirestore.instance.collection('groups').doc(groupId);

    try {
      // get the current pendingInvitations array
      DocumentSnapshot userDoc = await userRef.get();
      List<dynamic> currentInvites = (userDoc.data() as Map<String, dynamic>)['pendingInvitations'] ?? [];

      // Find and remove the specific invite
      currentInvites.removeWhere((invite) => invite['groupId'] == groupId);

      // Batch write to update both the groups array and pendingInvitations
      final batch = FirebaseFirestore.instance.batch();

      // Add group to user's groups
      batch.update(userRef, {
        'groups': FieldValue.arrayUnion([
          FirebaseFirestore.instance.collection('groups').doc(groupId)
        ]),
        // Update the pendingInvitations with the invite removed
        'pendingInvitations': currentInvites
      });

      // Update group document
      batch.update(groupRef, {
        'members': FieldValue.arrayUnion([userRef])
      });

      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group invite accepted successfully.')),
        );
        Navigator.of(context).pop(); // Close the dialog
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept invite: $e')),
        );
      }
    }
  }

  Future<void> _declineInvite(String? groupId) async {
    try {
      // Get reference to user document
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid);

      // Get current invites
      DocumentSnapshot userDoc = await userRef.get();
      List<dynamic> currentInvites = (userDoc.data() as Map<String, dynamic>)['pendingInvitations'] ?? [];
      
      // Remove the specific invite
      currentInvites.removeWhere((invite) => invite['groupId'] == groupId);

      // Update the pendingInvitations array
      await userRef.update({
        'pendingInvitations': currentInvites
      });

      // Update UI feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invite declined')),
        );
        Navigator.of(context).pop(); // Close the dialog
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to decline invite: $e')),
        );
      }
    }
  }
}
