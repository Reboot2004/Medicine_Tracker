 import 'package:flutter/material.dart';
 import 'package:cloud_firestore/cloud_firestore.dart';
 import 'homepage.dart';
//
// class UserDetailPage extends StatefulWidget {
//   final String username; // Change to accept a username
//
//   const UserDetailPage({Key? key, required this.username}) : super(key: key);
//
//   @override
//   _UserDetailPageState createState() => _UserDetailPageState();
// }
//
//
// class _UserDetailPageState extends State<UserDetailPage> {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   TextEditingController? nameController;
//   TextEditingController? morningController;
//   TextEditingController? noonController;
//   TextEditingController? eveningController;
//   TextEditingController? nightController;
//   TextEditingController? weeklyController;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchUserData();
//   }
//
//   void fetchUserData() async {
//     DocumentSnapshot userData = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.username) // Assuming username is used as a document ID
//         .get();
//
//     if (userData.exists) {
//       Map<String, dynamic> userDetails = userData.data() as Map<String, dynamic>;
//       // Initialize your controllers here
//       nameController = TextEditingController(text: userDetails['name']);
//       morningController = TextEditingController(text: userDetails['schedule']['daily']['morning'].join(', '));
//       noonController = TextEditingController(text: userDetails['schedule']['daily']['afternoon'].join(', '));
//       eveningController = TextEditingController(text: userDetails['schedule']['daily']['evening'].join(', '));
//       nightController = TextEditingController(text: userDetails['schedule']['daily']['night'].join(', '));
//       weeklyController = TextEditingController(text: userDetails['schedule']['weekly'].join(', '));
//       setState(() {}); // This is important to refresh the UI with the loaded data
//     } else {
//       // Handle user not found scenario
//     }
//   }
//   Future<void> updateUser() async {
//     Map<String, dynamic> schedule = {
//       'daily': {
//         'morning': morningController?.text.split(',').map((item) => item.trim()).toList(),
//         'afternoon': noonController?.text.split(',').map((item) => item.trim()).toList(),
//         'evening': eveningController?.text.split(',').map((item) => item.trim()).toList(),
//         'night': nightController?.text.split(',').map((item) => item.trim()).toList(),
//       },
//       'weekly': weeklyController?.text.split(',').map((item) => item.trim()).toList(),
//     };
//
//     await _db.collection('users').doc(widget.username).update({
//       'name': nameController?.text ?? '',
//       'schedule': schedule,
//     }).then((_) {
//       print("User updated successfully");
//       Navigator.pop(context); // Optionally pop back to the previous screen after the update
//     }).catchError((error) {
//       print("Failed to update user: $error");
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit User Details'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(8.0),
//         child : SingleChildScrollView(
//         child: Column(
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(labelText: 'Name'),
//             ),
//             TextField(
//               controller: morningController,
//               decoration: InputDecoration(labelText: 'Morning Medication'),
//             ),
//             TextField(
//               controller: noonController,
//               decoration: InputDecoration(labelText: 'Afternoon Medication'),
//             ),
//             TextField(
//               controller: eveningController,
//               decoration: InputDecoration(labelText: 'Evening Medication'),
//             ),
//             TextField(
//               controller: nightController,
//               decoration: InputDecoration(labelText: 'Night Medication'),
//             ),
//             TextField(
//               controller: weeklyController,
//               decoration: InputDecoration(labelText: 'Weekly Medication'),
//             ),
//             // Include more fields for schedule if needed
//             ElevatedButton(
//               onPressed: updateUser,
//               child: Text('Save Changes'),
//             ),
//           ],
//         ),
//       ),
//     ));
//   }
// }
 class Medication {
   TextEditingController nameController;
   TextEditingController dosageController;

   Medication({required String name, required String dosage})
       : nameController = TextEditingController(text: name),
         dosageController = TextEditingController(text: dosage);
 }

class UserDetailPage extends StatefulWidget {
  final String username; // Change to accept a username

  const UserDetailPage({Key? key, required this.username}) : super(key: key);

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  TextEditingController? nameController;

  // Medications are now just lists of strings
  List<Medication> morningMedications = [];
  List<Medication> afternoonMedications = [];
  List<Medication> eveningMedications = [];
  List<Medication> nightMedications = [];
  List<Medication> weeklyMedications = [];


  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    DocumentSnapshot userData = await _db.collection('users').doc(
        widget.username).get();

    if (userData.exists) {
      Map<String, dynamic> userDetails = userData.data() as Map<String,
          dynamic>;
      setState(() {
        nameController = TextEditingController(text: userDetails['name']);
        // Parse medications for each time period correctly
        Map<String, dynamic> schedule = userDetails['schedule'];
        morningMedications = _parseMedications(schedule['daily']['morning']);
        afternoonMedications =
            _parseMedications(schedule['daily']['afternoon']);
        eveningMedications = _parseMedications(schedule['daily']['evening']);
        nightMedications = _parseMedications(schedule['daily']['night']);
        weeklyMedications = _parseMedications(schedule['weekly']);
      });
    } else {
      print("No user data found");
    }
  }

  List<Medication> _parseMedications(List<dynamic> medList) {
    // Ensure medList is not null before trying to map over it
    if (medList == null) return [];

    return medList.map((med) =>
        Medication(
          name: med['name'],
          dosage: med['dosage'],
        )).toList();
  }


  void updateUser() async {
    // Construct the schedule map to be updated in Firestore
    Map<String, dynamic> scheduleToUpdate = {
      'daily': {
        'morning': morningMedications,
        'afternoon': afternoonMedications,
        'evening': eveningMedications,
        'night': nightMedications,
      },
      'weekly': weeklyMedications,
    };

    try {
      // Update the user's document with the new schedule
      await _db.collection('users').doc(widget.username).update({
        'name': nameController?.text ?? widget.username,
        // Update name if changed
        'schedule': scheduleToUpdate,
        // Update the schedule
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User updated successfully')),
      );

      // Optionally navigate back or refresh the page
      Navigator.pop(context);
    } catch (error) {
      // Handle any errors
      print("Failed to update user: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 20),
              Text('Medications', style: Theme
                  .of(context)
                  .textTheme
                  .headline6),
              _buildMedicationSection('Morning Medications', morningMedications),
              _buildMedicationSection('Afternoon Medications', afternoonMedications),
              _buildMedicationSection('Evening Medications', eveningMedications),
              _buildMedicationSection('Night Medications', nightMedications),
              _buildMedicationSection('Weekly Medications', weeklyMedications),
              ElevatedButton(
                onPressed: updateUser,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationSection(String title, List<Medication> medications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme
            .of(context)
            .textTheme
            .headline6),
        ...medications.map((medication) =>
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: medication.nameController,
                    decoration: InputDecoration(labelText: 'name'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: medication.dosageController,
                    decoration: InputDecoration(labelText: 'dosage'),
                  ),
                ),
              ],
            )),
      ],
    );
  }
}