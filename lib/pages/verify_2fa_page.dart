import 'package:flutter/material.dart';
import 'package:flutter_auth_app/services/auth_service.dart';

import 'home_page.dart';

class Verify2FAPage extends StatelessWidget {
  final String username;
  final TextEditingController _codeController = TextEditingController();
  final AuthService _authService = AuthService(); // Instance of AuthService

  Verify2FAPage({required this.username, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify 2FA'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _codeController,
                decoration:
                    const InputDecoration(labelText: 'Verification Code'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _authService.verify2FA(
                        username, _codeController.text);
                    // Navigate to the home page after successful verification
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: const Text('Verify'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
