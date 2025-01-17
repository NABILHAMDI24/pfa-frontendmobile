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
              Colors.blue.shade800,
              Colors.blue.shade400
            ], // Gradient background
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0), // Padding for the content
            child: Card(
              elevation: 8, // Card elevation
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16), // Rounded corners for the card
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0), // Padding inside the card
                child: FormBuilder(
                  key: _formKey, // Form key for validation
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Minimize the column size
                    children: <Widget>[
                      // Lock Icon
                      const Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16), // Spacing

                      // Sign In Title
                      const Text(
                        'Sign In', // Changed "Login" to "Sign In"
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 24), // Spacing

                      // Username Input Field
                      FormBuilderTextField(
                        name: 'username',
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon:
                              Icon(Icons.person), // Icon for the input field
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators
                              .required(), // Username is required
                        ]),
                      ),
                      const SizedBox(height: 16), // Spacing

                      // Password Input Field
                      FormBuilderTextField(
                        name: 'password',
                        obscureText: true, // Hide the password
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon:
                              Icon(Icons.lock), // Icon for the input field
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators
                              .required(), // Password is required
                          FormBuilderValidators.minLength(
                              6), // Minimum password length
                        ]),
                      ),

                      // 2FA Code Input Field (Shown after first step)
                      if (_show2FAInput) ...[
                        const SizedBox(height: 16), // Spacing
                        FormBuilderTextField(
                          name: 'code',
                          decoration: const InputDecoration(
                            labelText: '2FA Code',
                            prefixIcon: Icon(
                                Icons.security), // Icon for the input field
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators
                                .required(), // 2FA code is required
                          ]),
                        ),
                      ],

                      // Error Message (Shown if there's an error)
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16), // Spacing
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red, // Red color for error messages
                            fontSize: 14,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24), // Spacing

                      // Sign In Button
                      _isLoading
                          ? const CircularProgressIndicator() // Show loading indicator
                          : ElevatedButton(
                              onPressed: _onSubmit, // Handle login submission
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, // Button color
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 16), // Button padding
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      12), // Rounded corners
                                ),
                              ),
                              child: const Text(
                                'Sign In', // Changed "Login" to "Sign In"
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors
                                      .white, // White color for the button text
                                ),
                              ),
                            ),

                      const SizedBox(height: 16), // Spacing

                      // Sign Up Button
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, '/signup'); // Navigate to the SignUpPage
                        },
                        child: const Text(
                          'Don\'t have an account? Sign Up',
                          style: TextStyle(color: Colors.blue), // Text color
                        ),
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
