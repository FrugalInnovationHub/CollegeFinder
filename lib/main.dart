import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/features/user_auth/presentation/pages/CommonFooter.dart';
import 'package:myapp/features/user_auth/presentation/pages/Tasks.dart';

import 'features/app/splash_screen/splash_screen.dart';
import 'features/user_auth/presentation/pages/Student_choose_grade.dart';
import 'features/user_auth/presentation/pages/login_page.dart';
import 'features/user_auth/presentation/pages/sign_up_page.dart';



Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBwlXZjDodx4lvfLnak8Hp7aMJb25I9z_o",
        appId: "1:36597009887:android:e97af98db4a0597b53486a",
        messagingSenderId: "36597009887",
        projectId: "college-finder-54f2c",
        // Your web Firebase config options
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => SplashScreen(
                child: LoginPage(),
              ),
            );
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginPage());
          case '/signUp':
            return MaterialPageRoute(builder: (context) => SignUpPage());
          case '/home':
            return MaterialPageRoute(builder: (context) => StudentChooseGrade());
          case '/tasks':
          // Extract grade from the route arguments
            final String grade = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => TasksPage(grade: grade, color: Colors.blue),
            );
          case '/choosegrade':
            return MaterialPageRoute(builder: (context) => StudentChooseGrade());
          case '/commonfooter':
            return MaterialPageRoute(builder: (context) => CommonFooter());
        // Add cases for other routes as needed
          default:
            return null;
        }
      },
    );
  }
}
