import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(TaskApp());

class Task {
  String title;
  bool isCompleted;

  Task({required this.title, this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {'title': title, 'isCompleted': isCompleted};
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(title: map['title'], isCompleted: map['isCompleted']);
  }
}

class TaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TaskHomePage(),
    );
  }
}

class TaskHomePage extends StatefulWidget {
  @override
  _TaskHomePageState createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  List<Task> _tasks = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    _prefs = await SharedPreferences.getInstance();
    List<String>? storedTasks = _prefs.getStringList('tasks');
    if (storedTasks != null) {
      setState(() {
        _tasks = storedTasks
            .map((taskJson) => Task.fromMap(json.decode(taskJson)))
            .toList();
      });
    }
  }

  void _saveTasks() {
    List<String> taskList = _tasks.map((task) => json.encode(task.toMap())).toList();
    _prefs.setStringList('tasks', taskList);
  }

  void _addTask(String title) {
    setState(() {
      _tasks.add(Task(title: title));
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _toggleTaskComplete(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
    _saveTasks();
  }

  void _showAddTaskDialog() {
    String taskText = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Task'),
        content: TextField(
          autofocus: true,
          onChanged: (value) => taskText = value,
          decoration: InputDecoration(hintText: 'Enter task title'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (taskText.isNotEmpty) {
                _addTask(taskText);
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Management'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddTaskDialog,
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? Center(child: Text('No tasks added.'))
          : ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                task.isCompleted
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: task.isCompleted ? Colors.green : null,
              ),
              onPressed: () => _toggleTaskComplete(index),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTask(index),
            ),
          );
        },
      ),
    );
  }
}
