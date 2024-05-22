// lib/main.dart

import 'package:flutter/material.dart';
import 'package:myapp/features/user_auth/presentation/pages/Tasks.dart';
import 'package:myapp/global/common/Header.dart' as CommonHeader;

class StudentChooseGrade extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader.Header(dynamicText: "Your Grade", showBackArrow: false),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/backgg.jpg', // Replace with your background image asset path
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Text(
                    'Choose Your Grade',
                    style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'MadimiOne',
                    ),
                  ),
                ),
                SizedBox(height: 30),
                OptionCard(
                  title: '9th Grade',
                  onTap: () {
                    navigateToTasks(context, '9th Grade');
                  },
                ),
                SizedBox(height: 20),
                OptionCard(
                  title: '10th Grade',
                  onTap: () {
                    navigateToTasks(context, '10th Grade');
                  },
                ),
                SizedBox(height: 20),
                OptionCard(
                  title: '11th Grade',
                  onTap: () {
                    navigateToTasks(context, '11th Grade');
                  },
                ),
                SizedBox(height: 20),
                OptionCard(
                  title: '12th Grade',
                  onTap: () {
                    navigateToTasks(context, '12th Grade');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void navigateToTasks(BuildContext context, String grade) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TasksPage(grade: grade),
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  OptionCard({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.deepPurple[50] ?? Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Adjust the color and opacity as needed
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // Offset to create a little shadow below the container
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.deepPurple[400],
                    fontFamily: 'MadimiOne',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
