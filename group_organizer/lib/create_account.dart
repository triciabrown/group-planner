import 'package:flutter/material.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  // Controllers for the text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Create a New Account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                hintText: 'Enter your password',
              ),
              obscureText: true, // Hide password input
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle account creation logic here
                String email = _emailController.text;
                String password = _passwordController.text;
                // Validate inputs and create the account
                _createAccount(email, password);
              },
              child: Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }

  // Simulated method to handle account creation logic
  void _createAccount(String email, String password) {
    // Implement account creation logic here (e.g., API call)
    // For now, we'll just print the email and password to the console
    if (email.isNotEmpty && password.isNotEmpty) {
      print('Creating account with email: $email and password: $password');
      // You can add further logic to handle errors, validations, and success here
    } else {
      // Show a message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers when the page is closed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
