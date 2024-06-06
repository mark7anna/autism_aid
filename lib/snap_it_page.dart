import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SnapItPage extends StatefulWidget {
  @override
  _SnapItPageState createState() => _SnapItPageState();
}

class _SnapItPageState extends State<SnapItPage> {
  File? _imageFile;

  // Function to handle picking an image from the device gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snap It'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200, // Adjust width as needed
                height: 200, // Adjust height as needed
                child: _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        fit: BoxFit
                            .cover, // Ensure the image covers the entire container
                      )
                    : Text('No image selected'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () =>
                    _pickImage(ImageSource.gallery), // Choose from gallery
                child: Text('Choose Image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () =>
                    _pickImage(ImageSource.camera), // Take a picture
                child: Text('Take Picture'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Placeholder for future functionality associated with the play button
                },
                child: Text('Play'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
