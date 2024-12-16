import 'package:flutter/material.dart';
import 'package:noteapp/models/Database.dart';
import '../models/note.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EditScreen extends StatefulWidget {
  final Note? note;
  const EditScreen({Key? key, this.note});
  @override
  State<EditScreen> createState() => _EditScreenState();
}
class _EditScreenState extends State<EditScreen> {
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  late bool isDarkMode;
  Color _selectedColor = Colors.blue; // Default color

  // final DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    _fetchDarkModeStatus();
    super.initState();
    if (widget.note != null) {
      _titleController = TextEditingController(text: widget.note!.title);
      _contentController = TextEditingController(text: widget.note!.content);
      _selectedColor = widget.note!.color;
    }
  }

  void _fetchDarkModeStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? true; // Default is Dark mode
    });
  }

  void toggleDarkMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = !isDarkMode;
      prefs.setBool('isDarkMode', isDarkMode);
    });
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                setState(() => _selectedColor = color);
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final Color foregroundColor = isDarkMode ? Colors.white : Colors.black;
    final Color hintTextColor = isDarkMode ? Colors.grey : Colors.grey.shade800;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: const EdgeInsets.all(0),
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800.withOpacity(.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _showColorPicker,
                child: Text('Choose Color'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(_selectedColor),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                TextField(
                  controller: _titleController,
                  style: TextStyle(color: foregroundColor, fontSize: 30),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Title',
                    hintStyle: TextStyle(color: hintTextColor, fontSize: 30),
                  ),
                ),
                TextField(
                  controller: _contentController,
                  style: TextStyle(color: foregroundColor),
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type something here',
                    hintStyle: TextStyle(color: hintTextColor),
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (widget.note != null) {
            // Cập nhật ghi chú đã tồn tại
            Note updatedNote = Note(
              id: widget.note!.id,
              title: _titleController.text,
              content: _contentController.text,
              modifiedTime: DateTime.now(),
              color: _selectedColor,
            );
            await databaseHelper.update(updatedNote);
            Navigator.pop(context, updatedNote);
          } else {
            // Thêm mới ghi chú
            Note newNote = Note(
              title: _titleController.text,
              content: _contentController.text,
              modifiedTime: DateTime.now(),
              color: _selectedColor,
            );
            await DatabaseHelper.instance.create(newNote);
            Navigator.pop(context, newNote);
          }
        },
        elevation: 10,
        backgroundColor: Colors.grey.shade700,
        child: const Icon(Icons.save),
      ),
    );
  }
}