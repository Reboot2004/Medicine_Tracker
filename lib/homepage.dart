import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medicine_tracker/userdetails.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medicine Tracker')),
      body: StreamBuilder<List<User>>(
        stream: _firestoreService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          final users = snapshot.data!;
          return ListView(
            children: users.map((user) => ListTile(
              title: Text(user.name),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailPage(username: user.name), // Corrected
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _firestoreService.deleteUser(user.id),
              ),
            )).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddUserScheduleDialog,
      ),

    );
  }
  List<MedicationDetail> morningMedications = [];
  List<MedicationDetail> afternoonMedications = [];
// Repeat for other shifts

  void _showAddUserScheduleDialog() {
    TextEditingController userNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add User with Schedule'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: userNameController,
                  decoration: InputDecoration(hintText: 'Enter Name'),
                ),
                ...morningMedications.map((med) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: med.medication,
                          onChanged: (val) => med.medication = val,
                          decoration: InputDecoration(labelText: 'Medication'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          initialValue: med.dosage,
                          onChanged: (val) => med.dosage = val,
                          decoration: InputDecoration(labelText: 'Dosage'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                TextButton(
                  onPressed: () => setState(() {
                    morningMedications.add(MedicationDetail(medication: '', dosage: ''));
                  }),
                  child: Text('Add Another Morning Medication'),
                ),
                // Repeat for other shifts
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // Construct your schedule map here and call _firestoreService.addUser()
                // Remember to include all shifts and their respective medications and dosages
                Navigator.of(context).pop(); // Close the dialog after submission
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

}

class MedicationDetail {
  String medication;
  String dosage;

  MedicationDetail({required this.medication, required this.dosage});
}


class User {
  String id;
  String name;
  Map<String, dynamic> schedule;

  User({required this.id, required this.name, required this.schedule});

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'],
      schedule: data['schedule'] ?? {},
    );
  }
}

class FirestoreService {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new user with a name and an empty schedule
  Future<void> addUser(String username, Map<String, dynamic> schedule) async {
    // Use the username as the document ID
    await _db.collection('users').doc(username).set({
      'name': username,
      'schedule': schedule
    });
  }

  // Delete a user by ID
  Future<void> deleteUser(String userId) async {
    await _db.collection('users').doc(userId).delete();
  }

  // Stream of users list
  Stream<List<User>> getUsers() {
    return _db.collection('users').snapshots().map((snapshot) => snapshot.docs.map((doc) => User.fromFirestore(doc)).toList());
  }
}
