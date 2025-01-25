import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as img;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image; // Variable to store the captured image
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance

  // Function to capture an image using the device's camera
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return; // If no photo is taken, return

      // Read the image from file
      final bytes = await photo.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      // Adjust the orientation
      final fixedImage = img.bakeOrientation(originalImage!);

      // Save the fixed image
      final fixedImagePath = '${photo.path}_fixed.jpg';
      await File(fixedImagePath).writeAsBytes(img.encodeJpg(fixedImage));

      setState(() {
        _image = File(fixedImagePath);
      });
    } catch (e) {
      // Show an error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e')),
      );
    }
  }

  // Function to send the image to the backend for processing
  Future<void> _scanImage() async {
    if (_image == null) {
      // Show an error message if no image is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image to scan.')),
      );
      return;
    }

    // Create a multipart request to send the image to the backend
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.107:8081/upload'), // Replace with your backend IP
    );
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    try {
      final response = await request.send(); // Send the request

      if (response.statusCode == 200) {
        // If the request is successful, parse the response
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);

        // Display the extracted information in a dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Extracted Information'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Name: ${data['name'] ?? 'N/A'}'),
                Text('Surname: ${data['surname'] ?? 'N/A'}'),
                Text('Birthdate: ${data['birthdate'] ?? 'N/A'}'),
                Text('Card Number: ${data['cardNumber'] ?? 'N/A'}'),
                Text('Address: ${data['address'] ?? 'N/A'}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Show an error message if the request fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to scan image. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Show an error message if an exception occurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Scanner'), // App bar title
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_image != null) // Display the captured image if available
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4.0,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      _image!,
                      width: 300, // Adjust width for horizontal display
                      height: 200, // Set height to maintain aspect ratio
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 20), // Spacer
              // Button to take a photo
              ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 20), // Spacer
              // Button to scan the image
              ElevatedButton.icon(
                onPressed: _scanImage,
                icon: const Icon(Icons.scanner),
                label: const Text('Scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}