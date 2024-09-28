// ignore_for_file: empty_constructor_bodies

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' // new
    hide EmailAuthProvider, PhoneAuthProvider;    // new
import 'package:provider/provider.dart';          // new
import 'package:go_router/go_router.dart';

import 'app_state.dart';                          // new
import 'src/authentication.dart';                 // new


class WelcomePage extends StatelessWidget{
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
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
            // const SizedBox(height: 40),
            // const TextField(
            //   decoration: InputDecoration(
            //     labelText: 'Email',
            //     border: OutlineInputBorder(),
            //     filled: true,
            //     fillColor: Colors.white, // Fill input with white for visibility
            //   ),
            //   keyboardType: TextInputType.emailAddress,
            // ),
            // const SizedBox(height: 20),
            // const TextField(
            //   decoration: InputDecoration(
            //     labelText: 'Password',
            //     border: OutlineInputBorder(),
            //     filled: true,
            //     fillColor: Colors.white,
            //   ),
            //   obscureText: true,
            // ),
            const SizedBox(height: 20),
            Consumer<ApplicationState>(
            builder: (context, appState, _) => AuthFunc(
                loggedIn: appState.loggedIn,
                signOut: () {
                  FirebaseAuth.instance.signOut();
                }),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     context.go('/sign-in');
            //   },
            //   child: Text('Login'),
            // ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    // Navigate to CreateAccountPage using GoRouter
                    context.go('/create-account');
                  },
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Festie Bestie'),
  //     ),
  //     body: ListView(
  //       children: <Widget>[
  //         Image.asset('assets/codelab.png'),
  //         const SizedBox(height: 8),
  //         const IconAndDetail(Icons.calendar_today, 'October 30'),
  //         const IconAndDetail(Icons.location_city, 'San Francisco'),
  //                   Consumer<ApplicationState>(
  //           builder: (context, appState, _) => AuthFunc(
  //               loggedIn: appState.loggedIn,
  //               signOut: () {
  //                 FirebaseAuth.instance.signOut();
  //               }),
  //         ),
  //         const Divider(
  //           height: 8,
  //           thickness: 1,
  //           indent: 8,
  //           endIndent: 8,
  //           color: Colors.grey,
  //         ),
  //         const Header("What we'll be doing"),
  //         const Paragraph(
  //           'Join us for a day full of Firebase Workshops and Pizza!',
  //         ),
  //         Consumer<ApplicationState>(
  //           builder: (context, appState, _) => Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               switch (appState.attendees) {
  //                 1 => const Paragraph('1 person going'),
  //                 >= 2 => Paragraph('${appState.attendees} people going'),
  //                 _ => const Paragraph('No one going'),
  //               },
  //               if (appState.loggedIn) ...[
  //                 //enable logged in user to declare whether they're attending
  //                 YesNoSelection(
  //                   state: appState.attending,
  //                   onSelection: (attending) => appState.attending = attending,
  //                 ),
  //                 const Header('Discussion'),
  //                 GuestBook(
  //                   addMessage: (message) =>
  //                       appState.addMessageToChat(message),
  //                   messages: appState.guestBookMessages,
  //                 ),
  //               ],
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  
}