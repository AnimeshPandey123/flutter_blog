import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class CreatePostScreen extends StatefulWidget {
  final Function(String, String, String, String) onPostCreated;

  const CreatePostScreen({super.key, required this.onPostCreated});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {


  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _summaryController = TextEditingController();
  // final _imageController;

  File? _image;
  final picker = ImagePicker();

  Future<String> getCopiedFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    String imagePath = '$path/$timestamp' '.png';

    // copy the file to a new path
    if (_image != null) {
      final File newImage = await _image!.copy(imagePath);
    }
    return imagePath;
  }

  void _submitPost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title and Content are required!'))
      );
      return;
    }

    if (_image == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please select an image!'))
    );
    return;
  }
    // getting a directory path for saving
    
    String imagePath = await getCopiedFile();

    widget.onPostCreated(_titleController.text, _contentController.text, _summaryController.text, imagePath);
    Navigator.pop(context);
  }

  Future getImageFromGallery() async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  //Image Picker function to get image from camera
  Future getImageFromCamera() async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  //Show options to get image from camera or gallery
  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('Photo Gallery'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Blog Post')),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(),
          child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _summaryController,
              decoration: InputDecoration(labelText: 'Summary'),
              maxLines: 5,
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            TextButton(
              onPressed: showOptions,
              child: Text('Select Image'),
            ),
            Center(
              child: _image == null ? Text('No Image selected') : Image.file(_image!),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitPost,
              child: Text('Add Post'),
            ),
          ],
        ),
      ),
        )
      )
  
    );
  }
}
