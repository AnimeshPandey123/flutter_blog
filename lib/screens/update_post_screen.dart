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
  final Future<void> Function(int, String, String, String, String) onPostUpdated;

  const UpdatePostScreen({
    super.key,
    required this.id,
    required this.existingTitle,
    required this.existingSummary,
    required this.existingContent,
    required this.existingImagePath,
    required this.onPostUpdated,
  });

  @override
  _UpdatePostScreenState createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends State<UpdatePostScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _summaryController;
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingTitle);
    _contentController = TextEditingController(text: widget.existingContent);
    _summaryController = TextEditingController(text: widget.existingSummary);
    if (widget.existingImagePath.isNotEmpty) {
      _image = File(widget.existingImagePath);
    }
  }

  Future<String> getCopiedFile() async {
    if (_image == null) return widget.existingImagePath;
    final directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    String imagePath = '$path/$timestamp.png';

    await _image!.copy(imagePath);
    return imagePath;
  }

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
      _contentController.text,
      _summaryController.text,
      imagePath,
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
              ElevatedButton(
                onPressed: _submitPost,
                child: Text('Update Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}