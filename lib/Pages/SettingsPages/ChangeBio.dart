import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../UserProfilePage.dart';

class ChangeBio extends StatefulWidget {
  final Map<String, dynamic>? user;

  const ChangeBio({Key? key, required this.user}) : super(key: key);

  @override
  _ChangeBioState createState() => _ChangeBioState();
}

class _ChangeBioState extends State<ChangeBio> {
  TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize the bio controller with the current bio
    _bioController.text = widget.user?['bio'] ?? '';
  }

  Future<void> _updateBio() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String userId = widget.user?['uid'] ?? '';
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'bio': _bioController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bio successfully updated')),
      );

      // Update the bio in the user object
      Map<String, dynamic>? updatedUser = widget.user;
      updatedUser?['bio'] = _bioController.text;

      // Navigate back to UserProfilePage after bio update with the updated user object
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfilePage(user: updatedUser),
        ),
      );
    } catch (error) {
      print('Error updating bio: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating bio. Please try again later.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Bio'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        color: Colors.orange,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: 'Bio',
                hintText: 'Enter your bio',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              maxLines: null, // Allow multiline input
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _updateBio,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Update Bio'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }
}
