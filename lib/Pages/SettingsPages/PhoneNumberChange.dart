import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../UserProfilePage.dart';

class PhoneNumberChange extends StatefulWidget {
  final Map<String, dynamic>? user;

  const PhoneNumberChange({Key? key, required this.user}) : super(key: key);

  @override
  _PhoneNumberChangeState createState() => _PhoneNumberChangeState();
}

class _PhoneNumberChangeState extends State<PhoneNumberChange> {
  final TextEditingController _phoneController = TextEditingController();
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');
  bool _isLoading = false;

  void _updatePhoneNumber() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String phoneNumber = _phoneNumber.phoneNumber ?? '';
      await FirebaseFirestore.instance.collection('users').doc(widget.user!['uid']).update({
        'phone': phoneNumber,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone number updated successfully!')),
      );

      Map<String, dynamic>? updatedUser = widget.user;
      updatedUser?['phone'] = _phoneNumber.phoneNumber;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfilePage(user: updatedUser),
        ),
      );
    } catch (e) {
      print('Error updating phone number: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update phone number: $e')),
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
        title: Text('Change Phone Number'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        color: Colors.orange,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                _phoneNumber = number;
              },
              selectorConfig: SelectorConfig(
                selectorType: PhoneInputSelectorType.DROPDOWN,
              ),
              initialValue: _phoneNumber,
              textFieldController: _phoneController,
              inputDecoration: InputDecoration(
                labelText: 'Phone Number',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _updatePhoneNumber,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Update Phone Number'),
            ),
          ],
        ),
      ),
    );
  }
}
