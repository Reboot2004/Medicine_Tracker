import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'homepage.dart';

class UserDetailPage extends StatefulWidget {
  final String username; // Change to accept a username

  const UserDetailPage({Key? key, required this.username}) : super(key: key);

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}


class _UserDetailPageState extends State<UserDetailPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  TextEditingController? nameController;
  TextEditingController? morningController;
  TextEditingController? noonController;
  TextEditingController? eveningController;
  TextEditingController? nightController;
  TextEditingController? weeklyController;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.username) // Assuming username is used as a document ID
        .get();

    if (userData.exists) {
      Map<String, dynamic> userDetails = userData.data() as Map<String, dynamic>;
      // Initialize your controllers here
      nameController = TextEditingController(text: userDetails['name']);
      morningController = TextEditingController(text: userDetails['schedule']['daily']['morning'].join(', '));
      noonController = TextEditingController(text: userDetails['schedule']['daily']['afternoon'].join(', '));
      eveningController = TextEditingController(text: userDetails['schedule']['daily']['evening'].join(', '));
      nightController = TextEditingController(text: userDetails['schedule']['daily']['night'].join(', '));
      weeklyController = TextEditingController(text: userDetails['schedule']['weekly'].join(', '));
      setState(() {}); // This is important to refresh the UI with the loaded data
    } else {
      // Handle user not found scenario
    }
  }
  Future<void> updateUser() async {
    Map<String, dynamic> schedule = {
      'daily': {
        'morning': morningController?.text.split(',').map((item) => item.trim()).toList(),
        'afternoon': noonController?.text.split(',').map((item) => item.trim()).toList(),
        'evening': eveningController?.text.split(',').map((item) => item.trim()).toList(),
        'night': nightController?.text.split(',').map((item) => item.trim()).toList(),
      },
      'weekly': weeklyController?.text.split(',').map((item) => item.trim()).toList(),
    };

    await _db.collection('users').doc(widget.username).update({
      'name': nameController?.text ?? '',
      'schedule': schedule,
    }).then((_) {
      print("User updated successfully");
      Navigator.pop(context); // Optionally pop back to the previous screen after the update
    }).catchError((error) {
      print("Failed to update user: $error");
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child : SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: morningController,
              decoration: InputDecoration(labelText: 'Morning Medication'),
            ),
            TextField(
              controller: noonController,
              decoration: InputDecoration(labelText: 'Afternoon Medication'),
            ),
            TextField(
              controller: eveningController,
              decoration: InputDecoration(labelText: 'Evening Medication'),
            ),
            TextField(
              controller: nightController,
              decoration: InputDecoration(labelText: 'Night Medication'),
            ),
            TextField(
              controller: weeklyController,
              decoration: InputDecoration(labelText: 'Weekly Medication'),
            ),
            // Include more fields for schedule if needed
            ElevatedButton(
              onPressed: updateUser,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    ));
  }
}
