import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:college_finder/features/user_auth/presentation/pages/DocumentUpload.dart';
import 'package:college_finder/features/user_auth/presentation/pages/List.dart';
import 'package:college_finder/features/user_auth/presentation/pages/MeetingRecord.dart';
import 'package:college_finder/features/user_auth/presentation/pages/Video.dart';
import 'package:college_finder/global/common/Header.dart' as CommonHeader;
import 'package:college_finder/global/common/page_type.dart';
import '../../../../global/common/grade.dart';
import 'Memo.dart';

class FrostedGlassBox extends StatelessWidget {
  const FrostedGlassBox({
    Key? key,
    required this.theWidth,
    required this.theHeight,
    required this.theChild,
  }) : super(key: key);

  final double theWidth;
  final double theHeight;
  final Widget theChild;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: theWidth,
        height: theHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.13)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 4.0,
            sigmaY: 4.0,
          ),
          child: Container(
            color: Colors.transparent,
            child: theChild,
          ),
        ),
      ),
    );
  }
}

class TasksPage extends StatefulWidget {
  final Grade grade;

  TasksPage({required this.grade});
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late Grade selectedGrade;
  late List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchAndSetTasks(widget.grade);
  }

  void _onGradeChanged(Grade newGrade) {
    setState(() {
      selectedGrade = newGrade;
      fetchAndSetTasks(selectedGrade);
    });
  }

  Future<void> fetchAndSetTasks(Grade grade) async {
    String? userUUID = FirebaseAuth.instance.currentUser?.uid;
    final querySnapshotTasks = await FirebaseFirestore.instance
        .collection('Checklist')
        .doc(grade.grade)
        .collection('tasks')
        .get();

    final querySnapshotUsers = await FirebaseFirestore.instance
        .collection('users')
        .doc(userUUID)
        .collection('tasks')
        .get();

    setState(() {
      tasks = querySnapshotTasks.docs.map((doc) {
        // Find the corresponding mark from querySnapshotUsers
        var userTask;
        querySnapshotUsers.docs.forEach((userTaskDoc) {
          if (userTaskDoc.id == doc.id) {
            userTask = userTaskDoc;
          }
        });

        // If userTask is null, add the task to user's tasks with mark false
        if (userTask == null) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(userUUID)
              .collection('tasks')
              .doc(doc.id)
              .set({'mark': false})
              .then((value) {
            print('Task added to user\'s tasks successfully');
          }).catchError((error) {
            print('Failed to add task to user\'s tasks: $error');
            // Handle the error as needed
          });
        }

        List<String> documents = [];
        try {
          documents = List<String>.from(doc['documents']);
        } catch (e) {
          // Handle the exception, for example, print an error message
          print('Error fetching documents: $e');
          // You can also log the error or perform any other error handling as needed
        }

        return Task(
          id: doc.id,
          title: doc['title'],
          description: doc['description'],
          mark: userTask != null ? userTask['mark'] : false,
          pageType: PageTypeHelper.fromStringValue(doc['page_type']),
          rank: doc['rank'], // Use null-aware operator to handle null value
          documents: documents,
          grade: grade
        );
      }).toList();

      // Sort the tasks based on rank
      tasks.sort((a, b) => a.rank.compareTo(b.rank));
    });
  }

  double calculateProgress(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;

    int completedTasks = tasks.where((task) => task.mark).length;
    return completedTasks / tasks.length;
  }

  void updateTaskMark(Task task, bool newValue) {
    setState(() {
      task.mark = newValue;
    });

    String? userUUID = FirebaseAuth.instance.currentUser?.uid;
    // Update mark in the user's collection
    FirebaseFirestore.instance
        .collection('users')
        .doc(userUUID)
        .collection('tasks')
        .doc(task.id)
        .set({'mark': newValue}, SetOptions(merge: true)) // Use set with merge to create if not exists or update if exists
        .then((value) {
      print('User task mark updated successfully');
    }).catchError((error) {
      print('Failed to update user task mark: $error');
      // Handle the error as needed
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = calculateProgress(tasks);
    int completedTasks = tasks.where((task) => task.mark).length;
    int totalTasks = tasks.length;
    double progressPercent = (completedTasks/totalTasks)*100;

    return Scaffold(
      appBar: CommonHeader.Header(dynamicText: "Checklist", grade: widget.grade, onGradeChanged: _onGradeChanged),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/backgg.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Stack(
                  children: [
                    Container(
                      height: 20, // Set the height
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.lightGreen.withOpacity(0.3), // Lighter shade of green for background
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      width: MediaQuery.of(context).size.width * progress,
                      height: 20, // Set the height
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.green, // Green color for progress
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${progressPercent.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Colors.black, // Green color for progress text
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8), // Adjusted spacing
                Expanded(
                  child: FrostedGlassBox(
                    theWidth: double.infinity,
                    theHeight: MediaQuery.of(context).size.height * 0.7, // Adjusted height
                    theChild: TaskList(
                      tasks: tasks,
                      grade: widget.grade,
                      updateTaskMark: updateTaskMark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Grade grade;
  final Function(Task, bool) updateTaskMark;

  TaskList({
    required this.tasks,
    required this.grade,
    required this.updateTaskMark,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskCard(
          task: tasks[index],
          grade: grade,
          updateTaskMark: updateTaskMark,
        );
      },
    );
  }
}

Widget getPageWidget(Task task) {
  switch (task.pageType) {
    case PageType.memo:
      return MemoPage(task: task);
    case PageType.video:
      return VideoPage(task: task);
    case PageType.docUpload:
      return DocumentUploadPage(task: task);
    case PageType.dateTime:
      return MeetingRecordPage(task: task);
    case PageType.list:
      return ListPage(task: task);
  // Add cases for other page types if needed
    default:
      return DocumentUploadPage(task: task);
      //return MemoPage(task: task); // Return a default page or show an error message if the page type is not recognized
  }
}
class TaskCard extends StatefulWidget {
  final Task task;
  final Grade grade;
  final Function(Task, bool) updateTaskMark;

  TaskCard({
    required this.task,
    required this.grade,
    required this.updateTaskMark,
  });

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Timer _timer;
  bool _isAnimationStopped = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.1, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isAnimationStopped = true;
          });
        }
      });

    // Stop the animation after 5 seconds
    _timer = Timer(const Duration(seconds: 2), () {
      _controller.stop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Dismissible(
        key: Key(widget.task.id),
        direction: DismissDirection.endToStart,
        background: Stack(
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.0),
              color: Colors.green,
              child: Icon(Icons.add_card_rounded, color: Colors.white),
            ),
            Positioned.fill(
              right: 20.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: List.generate(
                  3,
                      (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white.withOpacity(0.6),
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        onDismissed: (direction) {
          // Handle swipe action (optional)
        },
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => getPageWidget(widget.task),
              ),
            );
          }
          return false;
        },
        child: Stack(
          children: [
            if (!_isAnimationStopped)
              SlideTransition(
                position: _offsetAnimation,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    ExpansionTile(
                      title: Text(
                        widget.task.title,
                        style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'MadimiOne',
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            widget.task.description,
                            style: TextStyle(
                              color: Colors.indigo,
                              fontSize: 15,
                              fontFamily: 'MadimiOne',
                            ),
                          ),
                        ),
                      ],
                      trailing: Checkbox(
                        value: widget.task.mark,
                        onChanged: (newValue) {
                          if (newValue != null) {
                            FirebaseFirestore.instance
                                .collection('Checklist')
                                .doc(widget.grade.grade)
                                .collection('tasks')
                                .doc(widget.task.id)
                                .update({'mark': newValue})
                                .then((value) {
                              print('Document updated successfully');
                            }).catchError((error) {
                              print('Failed to update document: $error');
                            });
                            widget.updateTaskMark(widget.task, newValue);
                          }
                        },
                      ),
                    ),
                    // Add arrows overlay
                    if (widget.task.rank == 1) // Replace with logic to check first task
                      Positioned(
                        right: 60.0,
                        child: Row(
                          children: List.generate(
                            3,
                                (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Icon(
                                Icons.arrow_back_ios_new_sharp,
                                color: Colors.black.withOpacity(0.4),
                                size: 16,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4.0,
                                    color: Colors.black.withOpacity(0.3),
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (_isAnimationStopped)
              Center(
                child: ExpansionTile(
                  title: Text(
                    widget.task.title,
                    style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'MadimiOne',
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        widget.task.description,
                        style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'MadimiOne',
                        ),
                      ),
                    ),
                  ],
                  trailing: Checkbox(
                    value: widget.task.mark,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        FirebaseFirestore.instance
                            .collection('Checklist')
                            .doc(widget.grade.grade)
                            .collection('tasks')
                            .doc(widget.task.id)
                            .update({'mark': newValue})
                            .then((value) {
                          print('Document updated successfully');
                        }).catchError((error) {
                          print('Failed to update document: $error');
                        });
                        widget.updateTaskMark(widget.task, newValue);
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TaskListPage extends StatelessWidget {
  final List<Task> tasks;
  final Grade grade;

  TaskListPage({required this.tasks, required this.grade});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Swipe right on a task to open its memo page',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return TaskCard(
                  task: tasks[index],
                  grade: grade,
                  updateTaskMark: (task, newValue) {
                    // Your updateTaskMark implementation here
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final int rank;
  final PageType pageType;
  final List<String> documents;
  final Grade grade;
  bool mark;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.mark,
    required this.pageType,
    required this.rank,
    required this.grade,
    required this.documents
  });
}
