import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'home_page.dart'; // Import the HomePage
// Import the Verify2FAPage
import '../services/auth_service.dart'; // Import the AuthService

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>(); // Form key for validation
  bool _isLoading = false; // Loading state
  bool _show2FAInput = false; // Show 2FA input after first step
  String? _errorMessage; // Error message to display
  String? _usernameFor2FA; // Username for 2FA verification
  bool _isPasswordVisible = false; // State to toggle password visibility

  final AuthService _authService = AuthService(); // Instance of AuthService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade900,
              Colors.indigo.shade500
            ], // Updated gradient colors
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20), // More rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'username',
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'password',
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(
                              6), // Minimum password length
                        ]),
                      ),
                      const SizedBox(height: 16),
                      if (_show2FAInput)
                        FormBuilderTextField(
                          name: 'code',
                          decoration: InputDecoration(
                            labelText: '2FA Code',
                            prefixIcon: Icon(Icons.security),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                      const SizedBox(height: 16),
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text('Sign In', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, '/signup'); // Navigate to the SignUpPage
                        },
                        child: Text('Don\'t have an account? Sign Up'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Handle Sign In Submission
  void _onSubmit() async {
    if (_formKey.currentState!.saveAndValidate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
        _errorMessage = null; // Reset error message
      });

      final formData = _formKey.currentState!.value; // Get form data
      final username = formData['username']; // Retrieve username
      final password = formData['password']; // Retrieve password
      final code = formData['code']; // Retrieve 2FA code (if applicable)

      try {
        if (!_show2FAInput) {
          // First step: Verify username and password
          final response = await _authService.login(username, password);
          setState(() {
            _show2FAInput = true; // Show 2FA input
            _usernameFor2FA = response['username']; // Store username for 2FA
            _isLoading = false; // Hide loading indicator
          });
        } else {
          // Second step: Verify 2FA code
          await _authService.verify2FA(_usernameFor2FA!, code);
          setState(() {
            _isLoading = false; // Hide loading indicator
          });
          // Navigate to the HomePage after successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false; // Hide loading indicator
          _errorMessage = e.toString(); // Show error message
        });
      }
    }
  }
}
