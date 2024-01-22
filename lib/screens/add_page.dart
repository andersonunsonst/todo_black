import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/screens/todo_list.dart';

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({super.key, this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo == null) {
      print('you can not call update whithout data');
      return;
    }

    final id = todo['_id'];
    final isCompleted = todo['is_completed'];
    final title = titleController.text;
    final description = descriptionController.text;

    if (widget.todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Tarefas' : 'Adc. Tarefas'),
      ),
      body: ListView(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: 'Título'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(hintText: 'descrição'),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: isEdit ? navigateTodoList : navigateToSubmitData,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(isEdit ? 'Atualizar' : 'Enviar'),
              ))
        ],
      ),
    );
  }

  void navigateToSubmitData() {
    submitData().then((result) {
      Navigator.of(context).pop();
    });
  }

  void navigateTodoList() {
    updateData().then((result) {
      Navigator.of(context).pop();
    });
  }

  Future<void> updateData() async {
    final todo = widget.todo;

    final id = todo?['_id'];
    final isCompleted = todo?['is_completed'];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      'title': title,
      'description': description,
      'is_completed': isCompleted
    };

    final url = 'http://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      titleController.text = '';
      descriptionController.text = '';
      showSuccessMessage('Sucesso ao Atualizar Tarefa');
    } else {
      showErrorMessage('Falha ao atualizar tarefa');
    }
  }

  Future<void> submitData() async {
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      'title': title,
      'description': description,
      'is_completed': false
    };

    final url = 'http://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 201) {
      titleController.text = '';
      descriptionController.text = '';
      showSuccessMessage('Tarefa criada com Sucesso');
    } else {
      showErrorMessage('A tarefa nao foi criada');
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
