# Medicine Tracker App

The Medicine Tracker App is a Flutter project designed to help users manage their medication schedules effectively. This app allows users to add medications for different times of the day (morning, afternoon, evening, and night) and for weekly reminders. Users can add multiple medications per shift, each with its dosage information, enhancing the app's functionality to cater to complex medication schedules.

## Features

- Add users with their medication schedules.
- Manage daily medication schedules with multiple medications per time slot (morning, afternoon, evening, night).
- Manage weekly medication schedules.
- Dynamic forms for adding multiple medications and dosages.
- Firestore integration for storing user data and medication schedules.

## Getting Started

To get started with the Medicine Tracker App, follow these steps:

### Prerequisites

- Flutter installed on your machine.
- An active Firebase project for the Firestore database integration.

### Installation

1. Clone the repository:
 ```
   git clone https://github.com/yourusername/medicine-tracker-app.git
   ```
2. Navigate to the project directory:
   ```
   cd medicine-tracker-app
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Setup Firebase:
   - Follow the [Firebase setup documentation](https://firebase.flutter.dev/docs/overview) for Flutter to integrate your Firebase project with this app.
   - Download your `google-services.json` and `GoogleService-Info.plist` files and place them in the appropriate directories as described in the setup documentation.

### Running the App

Run the app using the following command:

```
flutter run
```

## Usage

- Tap the "+" button to add a new user along with their medication schedule.
- To add multiple medications for a particular time slot, tap on "Add Another Medication" during user creation.
- Medication details can be viewed and edited by tapping on a user from the home screen.

## Contributing

Contributions to the Medicine Tracker App are welcome! Here are a few ways you can contribute:

- Report bugs and request features by creating issues.
- Contribute to the code by forking the repository, making your changes, and creating pull requests.


## License
This project is licensed under the MIT License - see the LICENSE file for details.
```
