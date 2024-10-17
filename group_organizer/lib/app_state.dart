import 'dart:async';       

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'chat_message.dart';   

enum Attending { yes, no, unknown }

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  bool accountCreated = false;
  bool onHomePage = false;
  bool completingSignIn = false;
  int _attendees = 0;
  int get attendees => _attendees;
  Attending _attending = Attending.unknown;
  StreamSubscription<DocumentSnapshot>? _groupSubscription;
  Attending get attending => _attending;

  void setCompleteSignIn(bool value) {
    completingSignIn = value;
    //notifyListeners(); // Notify any listeners that state has changed
  }

  set attending(Attending attending) {
    // final userDoc = FirebaseFirestore.instance
    //     .collection('attendees')
    //     .doc(FirebaseAuth.instance.currentUser!.uid);
    // if (attending == Attending.yes) {
    //   userDoc.set(<String, dynamic>{'attending': true});
    // } else {
    //   userDoc.set(<String, dynamic>{'attending': false});
    // }
  }

  StreamSubscription<QuerySnapshot>? _chatRoomSubscription;
  List<ChatMessage> _chatMessages = [];
  List<ChatMessage> get chatMessages => _chatMessages;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    // FirebaseFirestore.instance
    //     .collection('attendees')
    //     .where('attending', isEqualTo: true)
    //     .snapshots()
    //     .listen((snapshot) {
    //   _attendees = snapshot.docs.length;
    //   notifyListeners();
    // });
    
    FirebaseAuth.instance.userChanges().listen((user) {
      //subscribe to a query over the document collection when the user signs in
      if (user != null) {
        _loggedIn = true;
        // _chatRoomSubscription = FirebaseFirestore.instance
        //     .collection('chatroom')
        //     .orderBy('timestamp', descending: true)
        //     .snapshots()
        //     .listen((snapshot) {
        //   _chatMessages = [];
        //   for (final document in snapshot.docs) {
        //     _chatMessages.add(
        //       ChatMessage(
        //         name: document.data()['name'] as String,
        //         message: document.data()['text'] as String,
        //       ),
        //     );
        //    }
        //   //notifyListeners();
        // });

        // _groupSubscription = FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(user.uid)
        //     .snapshots()
        //     .listen((snapshot) {
        //   if (snapshot.data() != null) {
        //     if (snapshot.data()!['attending'] as bool) {
        //       _attending = Attending.yes;
        //     } else {
        //       _attending = Attending.no;
        //     }
        //   } else {
        //     _attending = Attending.unknown;
        //   }
        //   notifyListeners();
        //});
      } else {
        //unsubscribe when they sign out
        _loggedIn = false;
        _chatMessages = [];
        _chatRoomSubscription?.cancel();
        _groupSubscription?.cancel();
      }
      //notifyListeners();
    });
  }

  Future<DocumentReference> addMessageToChat(String message) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance
        .collection('chatroom')
        .add(<String, dynamic>{
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }
}