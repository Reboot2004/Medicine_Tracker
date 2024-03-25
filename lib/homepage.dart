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
    // Controllers for each medication count
    TextEditingController morningCountController = TextEditingController();
    TextEditingController afternoonCountController = TextEditingController();
    TextEditingController eveningCountController = TextEditingController();
    TextEditingController nightCountController = TextEditingController();
    TextEditingController weeklyCountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add User with Schedule'),
          content: SingleChildScrollView( // Use SingleChildScrollView for content that might not fit
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: userNameController,
                  decoration: InputDecoration(hintText: 'Enter Name'),
                ),
                TextField(
                  controller: morningCountController,
                  decoration: InputDecoration(hintText: 'Morning Medications Count'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: afternoonCountController,
                  decoration: InputDecoration(hintText: 'Afternoon Medications Count'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: eveningCountController,
                  decoration: InputDecoration(hintText: 'Evening Medications Count'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: nightCountController,
                  decoration: InputDecoration(hintText: 'Night Medications Count'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: weeklyCountController,
                  decoration: InputDecoration(hintText: 'Weekly Medications Count'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Parse counts or default to 0 if parsing fails
                Map<String, int> medicationCounts = {
                  'morning': int.tryParse(morningCountController.text) ?? 0,
                  'afternoon': int.tryParse(afternoonCountController.text) ?? 0,
                  'evening': int.tryParse(eveningCountController.text) ?? 0,
                  'night': int.tryParse(nightCountController.text) ?? 0,
                  'weekly': int.tryParse(weeklyCountController.text) ?? 0,
                };
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicationDetailsPage(
                      medicationCounts: medicationCounts,
                      userName: userNameController.text,
                    ),
                  ),
                );
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
class MedicationDetailsPage extends StatefulWidget {
  final Map<String, int> medicationCounts;
  final String userName;

  const MedicationDetailsPage({
    Key? key,
    required this.medicationCounts,
    required this.userName,
  }) : super(key: key);

  @override
  _MedicationDetailsPageState createState() => _MedicationDetailsPageState();
}

class _MedicationDetailsPageState extends State<MedicationDetailsPage> {
  late List<List<TextEditingController>> medicationControllers; // Controllers for each medication name
  late List<List<TextEditingController>> dosageControllers; // Controllers for each medication dosage

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each time period based on the medicationCounts map
    medicationControllers = [];
    dosageControllers = [];
    widget.medicationCounts.forEach((key, value) {
      medicationControllers.add(List.generate(value, (_) => TextEditingController()));
      dosageControllers.add(List.generate(value, (_) => TextEditingController()));
    });
  }


  @override
  void dispose() {
    // Dispose of all controllers
    medicationControllers.expand((element) => element).forEach((controller) => controller.dispose());
    dosageControllers.expand((element) => element).forEach((controller) => controller.dispose());
    super.dispose();
  }

  Widget buildMedicationInput(String timePeriod, String label) {
    int count = widget.medicationCounts[timePeriod] ?? 0; // Get the count for this time period
    int timeIndex = ['morning', 'afternoon', 'evening', 'night', 'weekly'].indexOf(timePeriod); // Determine the index based on timePeriod

    return Column(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        ...List.generate(count, (index) {
          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: medicationControllers[timeIndex][index],
                  decoration: InputDecoration(labelText: 'Medication ${index + 1}'),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: dosageControllers[timeIndex][index],
                  decoration: InputDecoration(labelText: 'Dosage ${index + 1}'),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }


  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Medication Details for ${widget.userName}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildMedicationInput('morning', 'Morning'),
            buildMedicationInput('afternoon', 'Afternoon'),
            buildMedicationInput('evening', 'Evening'),
            buildMedicationInput('night', 'Night'),
            buildMedicationInput('weekly', 'Weekly'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Construct the schedule map with both medication names and dosages
          Map<String, dynamic> schedule = {
            'daily': {
              'morning': List.generate(medicationControllers[0].length, (i) => {
                'name': medicationControllers[0][i].text.trim(),
                'dosage': dosageControllers[0][i].text.trim(),
              }),
              'afternoon': List.generate(medicationControllers[1].length, (i) => {
                'name': medicationControllers[1][i].text.trim(),
                'dosage': dosageControllers[1][i].text.trim(),
              }),
              'evening': List.generate(medicationControllers[2].length, (i) => {
                'name': medicationControllers[2][i].text.trim(),
                'dosage': dosageControllers[2][i].text.trim(),
              }),
              'night': List.generate(medicationControllers[3].length, (i) => {
                'name': medicationControllers[3][i].text.trim(),
                'dosage': dosageControllers[3][i].text.trim(),
              }),
            },
            'weekly': List.generate(medicationControllers[4].length, (i) => {
              'name': medicationControllers[4][i].text.trim(),
              'dosage': dosageControllers[4][i].text.trim(),
            }),
          };

          // Use FirestoreService to save the user with the constructed schedule
          final firestoreService = FirestoreService();
          await firestoreService.addUser(widget.userName, schedule);

          // Navigate back after saving
          Navigator.pop(context);
        },
        child: Icon(Icons.save),
      ),

    );
  }
}
