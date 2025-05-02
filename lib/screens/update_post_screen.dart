import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class UpdatePostScreen extends StatefulWidget {
  final int id;
  final String existingTitle;
  final String existingSummary;
  final String existingContent;
  final String existingImagePath;
  final bool existingIsFeatured;
  final Future<void> Function(int, String, String, String, String, bool) onPostUpdated;

  const UpdatePostScreen({
    super.key,
    required this.id,
    required this.existingTitle,
    required this.existingSummary,
    required this.existingContent,
    required this.existingImagePath,
    this.existingIsFeatured = false,
    required this.onPostUpdated,
  });

  @override
  _UpdatePostScreenState createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends State<UpdatePostScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _summaryController;
  late bool _isFeatured;
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingTitle);
    _contentController = TextEditingController(text: widget.existingContent);
    _summaryController = TextEditingController(text: widget.existingSummary);
    _isFeatured = widget.existingIsFeatured;
    if (widget.existingImagePath.isNotEmpty) {
      _image = File(widget.existingImagePath);
    }
  }

  // Copy file and returns the image path
  Future<String> getCopiedFile() async {
    if (_image == null) return widget.existingImagePath;
    
    // Check if we're already using the existing image path
    if (_image!.path == widget.existingImagePath) {
      return widget.existingImagePath;
    }
    
    final directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    String imagePath = '$path/$timestamp.png';

    await _image!.copy(imagePath);
    return imagePath;
  }

  // Submit the post
  void _submitPost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title and Content are required!')),
      );
      return;
    }

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image!'))
      );
      return;
    }

    String imagePath = await getCopiedFile();
    widget.onPostUpdated(
      widget.id,
      _titleController.text,
      _summaryController.text,
      _contentController.text,
      imagePath,
      _isFeatured,
    );
    Navigator.pop(context);
  }

  Future getImage(ImageSource source) async {
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Show options of image upload either photo gallery or camera
  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('Photo Gallery'),
            onPressed: () {
              Navigator.pop(context);
              getImage(ImageSource.gallery);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Camera'),
            onPressed: () {
              Navigator.pop(context);
              getImage(ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Blog Post')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _summaryController,
                decoration: InputDecoration(labelText: 'Summary'),
                maxLines: 3,
              ),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Content'),
                maxLines: 5,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _isFeatured,
                    onChanged: (bool? value) {
                      setState(() {
                        _isFeatured = value ?? false;
                      });
                    },
                  ),
                  Text('Feature this post'),
                ],
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: showOptions,
                child: Text('Select Image'),
              ),
              Center(
                child: _image == null
                    ? Text('No Image selected')
                    : Image.file(_image!, height: 200),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitPost,
                  child: Text('Update Post'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}