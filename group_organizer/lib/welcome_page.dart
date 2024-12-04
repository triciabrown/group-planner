// ignore_for_file: empty_constructor_bodies

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'app_state.dart';
import 'src/authentication.dart';
import 'app_state.dart';  


class WelcomePage extends StatelessWidget{
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 110, 129, 236),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Hello there FestieBestie!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Text color for better contrast
              ),
            ),
            const SizedBox(height: 20),
            // Consumer<ApplicationState>(
            // builder: (context, appState, _) => AuthFunc(
            //     loggedIn: appState.loggedIn,
            //     signOut: () {
            //       FirebaseAuth.instance.signOut();
            //     }),
            // ),
            ElevatedButton(
              onPressed: () {
                Provider.of<ApplicationState>(context, listen: false).setCompleteSignIn(true);
                context.go("/sign-in");
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}