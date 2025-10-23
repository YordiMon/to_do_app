import 'package:flutter/material.dart';

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
}

class ToDoListPage extends StatefulWidget {
  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final List<Task> _tasks = [];
  final TextEditingController _controller = TextEditingController();

  // 🎨 Puedes cambiar estos dos colores fácilmente
  final Color backgroundColor = const Color(0xFF1E1E1E); // Fondo principal
  final Color cardColor = const Color(0xFF2C2C2C); // Color de las tarjetas

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: _controller.text));
        _controller.clear();
      });
    }
  }

  void _deleteTask(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: const Text('Confirmar eliminación', style: TextStyle(color: Colors.lightBlueAccent, wordSpacing: 5, letterSpacing: 2)),
        content: const Text('¿Seguro que quieres eliminar esta tarea?', style: TextStyle(color: Colors.white70, wordSpacing: 5, letterSpacing: 2)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // ⬅️ aquí ajustas el radio
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70, wordSpacing: 5, letterSpacing: 2)),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white, wordSpacing: 5, letterSpacing: 2)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      setState(() {
        _tasks.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating, 
          margin: const EdgeInsets.only(right: 350, left: 350, bottom: 16), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.blueGrey,
          content: Container( 
            child: const Text(
              'Tarea eliminada',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, wordSpacing: 5, letterSpacing: 2),
            ),
          ),
        ),
      );
    }
  }

  void _toggleComplete(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, 
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 37, 37),
        title: const Padding(
          padding: EdgeInsets.only(left: 340.0, top: 8.0, bottom: 8.0),
          child: Text(
            'LISTA DE TAREAS POR HACER',
            style: TextStyle(
              color: Colors.lightBlueAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              wordSpacing: 5,
              letterSpacing: 2
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 350, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, wordSpacing: 5, letterSpacing: 2),
                    decoration: InputDecoration(
                      labelText: 'Agregar nueva tarea',
                      labelStyle: const TextStyle(color: Colors.blueGrey, wordSpacing: 5, letterSpacing: 2),
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
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
                  minimumSize: const Size(40, 45),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
              ],
            ),
            const SizedBox(height: 20),

            // Lista de tareas
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                            'No hay tareas pendientes',
                            style: TextStyle(fontSize: 16, color: Colors.blueGrey, wordSpacing: 5, letterSpacing: 2),
                          ),
                          Text(
                            '¡Agregue una nueva tarea!',
                            style: TextStyle(fontSize: 22, color: Colors.lightBlueAccent, wordSpacing: 5, letterSpacing: 2),
                          ),
                        ]
                      )
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: _tasks[index].isCompleted
                            ? const Color.fromARGB(255, 30, 60, 90)
                            : const Color.fromARGB(255, 57, 57, 57), 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              _tasks[index].title,
                              style: TextStyle(
                                wordSpacing: 5, letterSpacing: 2,
                                color: _tasks[index].isCompleted
                                    ? Colors.lightBlueAccent
                                    : Colors.white,
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
