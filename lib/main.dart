import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista de tareas',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
      ),
      home: ToDoListPage(),
    );
  }
}

class Task {
  String title;
  bool isCompleted;

  Task({required this.title, this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      isCompleted: map['isCompleted'],
    );
  }
}

class ToDoListPage extends StatefulWidget {
  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final List<Task> _tasks = [];
  final TextEditingController _controller = TextEditingController();

  final Color backgroundColor = const Color(0xFF1E1E1E);
  final Color cardColor = const Color(0xFF2C2C2C);

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Cargar tareas al iniciar
  }

  // Guardar tareas en SharedPreferences
  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasksString =
        _tasks.map((task) => jsonEncode(task.toMap())).toList();
    await prefs.setStringList('tasks', tasksString);
  }

  // Cargar tareas desde SharedPreferences
  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? tasksString = prefs.getStringList('tasks');
    if (tasksString != null) {
      setState(() {
        _tasks.clear();
        _tasks.addAll(
            tasksString.map((str) => Task.fromMap(jsonDecode(str))).toList());
      });
    }
  }

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: _controller.text));
        _controller.clear();
      });
      _saveTasks();
    }
  }

  void _deleteTask(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(
              color: Colors.lightBlueAccent,
              wordSpacing: 5,
              letterSpacing: 2),
        ),
        content: const Text(
          '¿Seguro que quieres eliminar esta tarea?',
          style:
              TextStyle(color: Colors.white70, wordSpacing: 5, letterSpacing: 2),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancelar',
              style:
                  TextStyle(color: Colors.white70, wordSpacing: 5, letterSpacing: 2),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
            ),
            child: const Text(
              'Eliminar',
              style:
                  TextStyle(color: Colors.white, wordSpacing: 5, letterSpacing: 2),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      setState(() {
        _tasks.removeAt(index);
      });
      _saveTasks();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.blueGrey,
          content: const Text(
            'Tarea eliminada',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold, wordSpacing: 5, letterSpacing: 2),
          ),
        ),
      );
    }
  }

  void _toggleComplete(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    // Tamaño de pantalla para responsividad
    double screenWidth = MediaQuery.of(context).size.width;
    double paddingHorizontal = screenWidth > 600 ? 50 : 20;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 37, 37),
        title: const Text(
          'LISTA DE TAREAS POR HACER',
          style: TextStyle(
              color: Colors.lightBlueAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              wordSpacing: 5,
              letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(
                        color: Colors.white, wordSpacing: 5, letterSpacing: 2),
                    decoration: InputDecoration(
                      labelText: 'Agregar nueva tarea',
                      labelStyle: const TextStyle(
                          color: Colors.blueGrey, wordSpacing: 5, letterSpacing: 2),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    minimumSize: const Size(45, 45),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'No hay tareas pendientes',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey,
                                wordSpacing: 5,
                                letterSpacing: 2),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '¡Agregue una nueva tarea!',
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.lightBlueAccent,
                                wordSpacing: 5,
                                letterSpacing: 2),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: _tasks[index].isCompleted
                              ? const Color.fromARGB(255, 30, 60, 90)
                              : cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              _tasks[index].title,
                              style: TextStyle(
                                wordSpacing: 5,
                                letterSpacing: 2,
                                color: _tasks[index].isCompleted
                                    ? Colors.lightBlueAccent
                                    : Colors.white,
                                decoration: _tasks[index].isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            leading: Checkbox(
                              value: _tasks[index].isCompleted,
                              onChanged: (_) => _toggleComplete(index),
                              activeColor: Colors.lightBlueAccent,
                              checkColor: Colors.white,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.blueGrey),
                              onPressed: () => _deleteTask(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
