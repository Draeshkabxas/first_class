import 'package:first_class/provider/NotesProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class NotesScreen extends StatefulWidget {
  NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {

  @override
  Widget build(BuildContext context) {
    NotesProvier watcher=context.watch<NotesProvier>();
    NotesProvier provider=context.read<NotesProvier>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        actions: [
          IconButton(onPressed: (){
            watcher.getNotes();
          }, icon: const Icon(Icons.refresh))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: (watcher.notes == null || watcher.notes?.length == 0 )
          ? const Center(
              child: Text(
              "No Notes",
              style: TextStyle(fontSize: 32),
            ))
          : ListView.separated(
              itemBuilder: (context, index) => GestureDetector(
                child: Dismissible(
                  key: Key("hello"),
                  background: Container(
                    color: Colors.red,
                    child: Align(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Icon(Icons.delete),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                    onDismissed: (_) {
                    provider.deleteNote(watcher.notes?[index]["id"]);
                      setState(() {
                      });
                    },
                  confirmDismiss: (direction) async {
                      bool delete = true;
                      final snackbarController = ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Deleted ${watcher.notes?[index]["content"]}'),
                          action: SnackBarAction(label: 'Undo', onPressed: () => delete = false),
                        ),
                      );
                      await snackbarController.closed;
                      return delete;
                  },
                  child: ListTile(
                    title: Text(watcher.notes?[index]["content"]),
                  ),
                ),
                    ),
              separatorBuilder: (context, index) => const SizedBox(
                    height: 16,
                  ),
              itemCount: watcher.notes!.length),
    );
  }
}

class AddNoteScreen extends StatefulWidget {
  AddNoteScreen({Key? key}) : super(key: key);

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  var noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    NotesProvier provider=context.read<NotesProvier>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a note"),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  label: Text("Note"),
                  icon: Icon(Icons.note),
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                controller: noteController,
                style: const TextStyle(fontSize: 24),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          provider.insertToDatabase(noteController.text);
          Navigator.pop(context);
        },
        child: const Icon(Icons.note_add),
      ),
    );
  }
}
