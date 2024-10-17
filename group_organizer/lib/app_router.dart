// app_router.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:group_organizer/create_group_page.dart';
import 'package:provider/provider.dart';

import 'welcome_page.dart';
import 'home_page.dart';
import 'app_state.dart';  

class AppRouter {
  final ApplicationState appState;

  AppRouter(this.appState);

  GoRouter get router => GoRouter(
    initialLocation: "/home-page",
    refreshListenable: appState, // listen to appState changes
    redirect: (context, state) {
      if (!appState.loggedIn && !appState.completingSignIn){
        return '/welcome-page';
      }
      return null;
    },
    routes: [
      // GoRoute(
      //   name: "root",
      //   path: "/",
      //   builder: (context, state) => HomePage(),
      // ),
      GoRoute(
        name:"/sign-in",
        path: '/sign-in',
        builder: (context, state) {
          return SignInScreen(
            actions: [
              ForgotPasswordAction(((context, email) {
                final uri = Uri(
                  path: '/sign-in/forgot-password',
                  queryParameters: <String, String?>{
                    'email': email,
                  },
                );
                context.push(uri.toString());
              })),
              AuthStateChangeAction(((context, state) {
                final user = switch (state) {
                  SignedIn state => state.user,
                  UserCreated state => state.credential.user,
                  _ => null
                };
                if (user == null) return;

                if (state is UserCreated) {
                  user.updateDisplayName(user.email!.split('@')[0]);
                  createNewUser(user);
                }
                if (!user.emailVerified) {
                  user.sendEmailVerification();
                  const snackBar = SnackBar(
                      content: Text(
                          'Please check your email to verify your email address'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                context.go('/home-page');
              })),
            ],
          );
        },
        routes: [
          GoRoute(
            name: "forgot-password",
            path: 'forgot-password',
            builder: (context, state) {
              final arguments = state.uri.queryParameters;
              return ForgotPasswordScreen(
                email: arguments['email'],
                headerMaxExtent: 200,
              );
            },
          ),
        ],
      ),
      GoRoute(
        name: "/home-page",
        path: '/home-page',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            name: "profile",
            path: "profile",
            builder: (context, state) => Scaffold(
              appBar: AppBar(
                title: const Text('Profile'),
              ),
              body: const ProfileScreen(),
            ),
          ),
          GoRoute(
            name: "create-group",
            path: "create-group",
            builder: (context, state) => const CreateGroupPage(),
          ),
        ],

      ),
      GoRoute(
        //redirect: appState.loggedIn ? return context.namedLocation("/home-page") : return "/welcome-page",
        name:"/welcome-page",
        path: '/welcome-page',
        builder: (context, state) {
          return const WelcomePage ();
        },
      ),
    ],
  );

  Future<void> createNewUser(User user) async {
    try {
      final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
      DocumentReference newUser = usersCollection.doc(user.uid);

      Map<String,dynamic> userData = {
        'userId': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'groupIds': [], // user has no groups on first creation
      };

      await newUser.set(userData);

    } catch (e) {
      print('Error adding group: $e');
    }
  }

}
