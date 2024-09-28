// app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:provider/provider.dart';

import 'welcome_page.dart';
import 'home_page.dart';
import 'app_state.dart';  

class AppRouter {
  final ApplicationState appState;

  AppRouter(this.appState);

  GoRouter get router => GoRouter(
        refreshListenable: appState, // listen to appState changes
        // redirect: (context, state) {
        //   return '/home-page';
        // },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              final appState = context.read<ApplicationState>();
              return appState.loggedIn ? const HomePage() : const WelcomePage();
            },
            routes: [
              GoRoute(
                path: 'sign-in',
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
                        }
                        if (!user.emailVerified) {
                          user.sendEmailVerification();
                          const snackBar = SnackBar(
                              content: Text(
                                  'Please check your email to verify your email address'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                        context.pushReplacement('/');
                      })),
                    ],
                  );
                },
                routes: [
                  GoRoute(
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
                path: 'profile',
                builder: (context, state) {
                  return ProfileScreen(
                    providers: const [],
                    actions: [
                      //we're immediately jumping to the signedOutAction here even when appState.loggedIn==true
                      SignedOutAction((context) {
                        context.pushReplacement('/');
                      }),
                    ],
                  );
                },
              ),
              GoRoute(
                path: 'home-page',
                builder: (context, state) {
                  return appState.loggedIn ? const HomePage (): const WelcomePage();
                },
              ),
            ],
          ),
        ],
      );
}
