import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noteapp/models/Database.dart';
import 'package:noteapp/models/note.dart';
import 'package:noteapp/screens/edit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool isDarkMode;
  bool isAscending = true;
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  late List<Note> filteredNotes;// Biến để theo dõi trạng thái sắp xếp

  @override
  void initState() {
    _fetchDarkModeStatus();
    super.initState();
    _refreshNoteList();
  }

  void _refreshNoteList() async {
    List<Note> notes = await databaseHelper.readAllNotes();
    List<Note> sortedNotes = await sortNotesByModifiedTimeFromDatabase(isAscending);
    setState(() {
      filteredNotes = sortedNotes;
    });
  }

  void _fetchDarkModeStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? true;
    });
  }

  void toggleDarkMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = !isDarkMode;
      prefs.setBool('isDarkMode', isDarkMode);
      _refreshNoteList(); // Cập nhật lại danh sách ghi chú sau khi thay đổi chế độ tối/sáng
    });
  }

  Future<List<Note>> sortNotesByModifiedTimeFromDatabase(bool isAscending) async {
    final List<Note> sortedNotes = await databaseHelper.sortNotesByModifiedTime(isAscending);
    return sortedNotes;
  }

  void onSearchTextChanged(String searchText) async {
    List<Note> searchedNotes = await databaseHelper.searchNotes(searchText);
    setState(() {
      filteredNotes = searchedNotes;
    });
  }

  void deleteNote(int id) async {
    await databaseHelper.delete(id);
    _refreshNoteList(); // Cập nhật lại danh sách ghi chú sau khi xóa
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100;
    final Color foregroundColor = isDarkMode ? Colors.white : Colors.black;
    final Color searchFieldColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final Color hintTextColor =
        isDarkMode ? Colors.grey : Colors.grey.shade800;
    final Color notesColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notes',
                  style: TextStyle(fontSize: 30, color: notesColor),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: toggleDarkMode,
                      icon: Icon(
                        isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: foregroundColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        setState(() {
                          isAscending = !isAscending; // Đảo ngược trạng thái sắp xếp
                        });
                        filteredNotes = await sortNotesByModifiedTimeFromDatabase(isAscending);
                      },
                      padding: const EdgeInsets.all(0),
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800.withOpacity(.8),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: const Icon(
                          Icons.sort,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              onChanged: onSearchTextChanged,
              style: TextStyle(fontSize: 16, color: foregroundColor),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: "Search notes...",
                hintStyle: TextStyle(color: hintTextColor),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                fillColor: searchFieldColor,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 30),
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    color: filteredNotes[index].color,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        onTap: () async {
                          final editedNote = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  EditScreen(note: filteredNotes[index]),
                            ),
                          );
                          if (editedNote != null) {
                            await databaseHelper.update(editedNote);
                            _refreshNoteList();
                          }
                        },
                        title: RichText(
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                              text: '${filteredNotes[index].title} \n',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  height: 1.5),
                              children: [
                                TextSpan(
                                  text: filteredNotes[index].content,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                      height: 1.5),
                                )
                              ]),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Edited: ${DateFormat('EEE MMM d, yyyy h:mm a').format(filteredNotes[index].modifiedTime)}',
                            style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade800),
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            final result = await confirmDialog(context, filteredNotes[index].id!);
                            if (result != null && result) {
                              deleteNote(filteredNotes[index].id!);
                            }
                          },
                          icon: const Icon(
                            Icons.delete,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const EditScreen(),
            ),
          );

          if (newNote != null) {
            _refreshNoteList(); // Cập nhật lại danh sách ghi chú từ cơ sở dữ liệu
          }
        },
        elevation: 10,
        backgroundColor: Colors.grey.shade700,
        child: const Icon(
          Icons.add,
          size: 38,
        ),
      ),
    );
  }

  Future<dynamic> confirmDialog(BuildContext context, int id) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          icon: const Icon(
            Icons.info,
            color: Colors.grey,
          ),
          title: const Text(
            'Are you sure you want to delete?',
            style: TextStyle(color: Colors.white),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const SizedBox(
                  width: 60,
                  child: Text(
                    'Yes',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const SizedBox(
                  width: 60,
                  child: Text(
                    'No',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}