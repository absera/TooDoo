import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:toodoo/note/note_model.dart';
import 'package:toodoo/style/toodoo_styles.dart';
import 'package:toodoo/test.dart';
import 'package:toodoo/utils/about.dart';
import 'package:toodoo/utils/settings.dart';
import 'note/note_view.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:toast/toast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TooDoo',
      theme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
        primarySwatch: TooDooColors.primary,
        primaryColor: TooDooColors.primary,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: TooDooFonts.main,
      ),
      home: MyHomePage(title: 'TooDoo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Sorting
  String sortingMethod = "id";

  // chip
  bool isCompletedSelected = true;
  bool isIncompletedSelected = true;

  // context menu
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  List<String> choices = <String>[
    "Settings",
    "Delete Completed Tasks",
    "Delete All Tasks",
  ];

  // sort menu
  List<String> sortChoices = <String>[
    "Last Added First",
    "First Added First",
    "Most Urgent",
    "Least Urgent",
    "Most Important",
    "Least Important",
  ];

  // add new note
  String inputTitle = "";
  String inputBody = "";
  bool addButtonDisabled = true;

  // sliders
  double importanceSliderValue = 50;
  double urgencySliderValue = 50;

  // main build
  @override
  Widget build(BuildContext context) {
    return SwipeDetector(
      onSwipeUp: () {
        _showBottomSheet();
      },
      child: Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(color: TooDooColors.darkGrey),
          ),
          centerTitle: true,
          actions: [
            // below is context menu for sorting methods
            PopupMenuButton(
              icon: Icon(
                Icons.sort,
              ),
              elevation: 1.0,
              padding: EdgeInsets.all(0),
              onSelected: (choice) {
                setState(() {
                  if (choice == sortChoices[0]) {
                    sortingMethod = "id";
                  } else if (choice == sortChoices[1]) {
                    sortingMethod = "idDesc";
                  } else if (choice == sortChoices[2]) {
                    sortingMethod = "urgencyDesc";
                  } else if (choice == sortChoices[3]) {
                    sortingMethod = "urgencyAsc";
                  } else if (choice == sortChoices[4]) {
                    sortingMethod = "importanceDesc";
                  } else if (choice == sortChoices[5]) {
                    sortingMethod = "importanceAsc";
                  }
                });
              },
              itemBuilder: (BuildContext context) {
                return sortChoices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
            // below is context menu for setting and deleting operations
            PopupMenuButton(
              icon: Icon(
                Icons.more_horiz,
              ),
              elevation: 1.0,
              padding: EdgeInsets.all(0),
              onSelected: (choice) {
                setState(() {
                  if (choice == choices[0]) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Settings()),
                    );
                  } else if (choice == choices[1]) {
                    setState(() {
                      Note.deleteCompleted();
                      isCompletedSelected = false;
                    });
                  } else if (choice == choices[2]) {
                    setState(() {
                      Note.deleteAll();
                      isCompletedSelected = isIncompletedSelected = false;
                    });
                  }
                });
              },
              itemBuilder: (BuildContext context) {
                return choices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
          shadowColor: TooDooColors.none,
          backgroundColor: TooDooColors.none,
          iconTheme: IconThemeData(opacity: 0.8, color: TooDooColors.darkGrey),
        ),
        drawer: _drawer(),
        body: FutureBuilder(
          future: Note.fetch(sortingMethod),
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return Center(
                child: Text("Loading..."),
              );
            } else {
              if (snapshot.data.toString() == '[]') {
                return Center(
                  child: Text("Add Some Tasks"),
                );
              } else {
                return Container(
                  child: Column(
                    children: [
                      Wrap(
                        children: [
                          FilterChip(
                            label: Text('Not Done'),
                            labelStyle: TextStyle(
                                color: isIncompletedSelected
                                    ? TooDooColors.light
                                    : TooDooColors.dark),
                            selected: isIncompletedSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                isIncompletedSelected = !isIncompletedSelected;
                              });
                            },
                            selectedColor: TooDooColors.success,
                            checkmarkColor: TooDooColors.light,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          FilterChip(
                            label: Text('Done'),
                            labelStyle: TextStyle(
                                color: isCompletedSelected
                                    ? TooDooColors.light
                                    : TooDooColors.dark),
                            selected: isCompletedSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                isCompletedSelected = !isCompletedSelected;
                              });
                            },
                            selectedColor: TooDooColors.success,
                            checkmarkColor: TooDooColors.light,
                          )
                        ],
                      ),
                      Flexible(
                        // used notification listener to remove highlight color from listview
                        child: NotificationListener<
                            OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowGlow();
                            return false;
                          },
                          child: ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              NoteList notes = NoteList.fromJson(snapshot.data);
                              var note = notes.notes[index];
                              String title = note.title;
                              String body = note.body;
                              int id = note.id;
                              int cp = note.completed;
                              int urgency = note.urgency;
                              int importance = note.importance;
                              bool completed;
                              cp == 1 ? completed = true : completed = false;

                              if (!completed) {
                                if (isIncompletedSelected) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: TooDooColors.failure,
                                          child: Text(
                                            "${title[0]}",
                                            style: TextStyle(
                                                color: TooDooColors.light,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        title: Text("$title"),
                                        subtitle: Text(
                                          "$body",
                                          maxLines: 2,
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(
                                              Icons.radio_button_unchecked),
                                          onPressed: () {
                                            Note note = notes.notes[index];
                                            setState(() {
                                              note.complete();
                                            });
                                          },
                                          tooltip: "Mark As Done",
                                        ),
                                        onTap: () {
                                          _navigateToNoteView(
                                            context,
                                            notes,
                                            index,
                                            id,
                                          );
                                        },
                                        onLongPress: () {
                                          setState(() {
                                            notes.notes[index].delete();
                                          });
                                        },
                                      ),
                                      Divider(
                                        height: 2.0,
                                      ),
                                    ],
                                  );
                                } else {
                                  return Text("");
                                }
                              }
                              if (isCompletedSelected) {
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        child: Text(
                                          "${title[0]}",
                                        ),
                                        backgroundColor: TooDooColors.success,
                                      ),
                                      title: Text(
                                        "$title",
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontStyle: FontStyle.italic),
                                      ),
                                      subtitle: Text(
                                        "Done! $body",
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(Icons.check_circle_sharp, color: TooDooColors.success,),
                                        onPressed: () {
                                          Note note = notes.notes[index];
                                          setState(() {
                                            note.undone();
                                          });
                                        },
                                        tooltip: "Redo Task",
                                      ),
                                      onTap: () {
                                        Toast.show(
                                          "Long Press To Delete",
                                          context,
                                          duration: Toast.LENGTH_SHORT,
                                          gravity: Toast.CENTER,
                                          backgroundColor: TooDooColors.none,
                                          textColor: TooDooColors.dark,
                                        );
                                      },
                                      onLongPress: () {
                                        setState(() {
                                          notes.notes[index].delete();
                                        });
                                      },
                                    ),
                                    Divider(
                                      height: 2.0,
                                    )
                                  ],
                                );
                              }
                              return Text("");
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text("New Task"),
          onPressed: () {
            return _showBottomSheet();
          },
          backgroundColor: TooDooColors.success,
          foregroundColor: TooDooColors.light,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  _navigateToNoteView(
      BuildContext context, NoteList noteList, int index, int id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NoteView(
                noteList: noteList,
                index: index,
                id: id,
              )),
    );
    if (result) {
      setState(() {});
    }
  }

  _drawer() {
    return Drawer(
      elevation: 10.0,
      child: Column(
        children: [
          DrawerHeader(
              child: Container(
            width: MediaQuery.of(context).size.width,
            height: (MediaQuery.of(context).size.height) * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: TooDooColors.secondary,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.format_list_bulleted,
                  color: TooDooColors.light,
                ),
                Text("   "),
                Text(
                  "My TooDoo List",
                  style: TextStyle(
                    color: TooDooColors.light,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(children: [
              ListTile(
                leading: Icon(Icons.add_circle),
                title: Text("New Task"),
                onTap: () {
                  Navigator.pop(context);
                  _showBottomSheet();
                },
              ),
              Divider(
                height: 5.0,
              ),
              ListTile(
                leading: Icon(Icons.settings_rounded),
                title: Text("Settings"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Settings()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text("About"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => About()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.update),
                title: Text("Update"),
                onTap: () {},
              ),
            ]),
          )
        ],
      ),
    );
  }

  _showBottomSheet() {
    return showModalBottomSheet(
        elevation: 10.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.0))),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          {
            return StatefulBuilder(builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _sliders(context, state),
                    SizedBox(
                      height: 3.0,
                    ),
                    SizedBox(
                      height: 3.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(6.0, 5.0, 6.0, 1.0),
                            child: Column(
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                      suffixIcon: addButtonDisabled
                                          ? IconButton(
                                              onPressed: () {},
                                              icon: Icon(
                                                Icons.send,
                                                color: TooDooColors.darkGrey,
                                              ),
                                              tooltip: "Write Title",
                                            )
                                          : IconButton(
                                              onPressed: () {
                                                _addNewNote(
                                                    inputTitle, inputBody);
                                                Navigator.pop(context, true);
                                                setState(() {
                                                  inputTitle = "";
                                                  inputBody = "";
                                                  addButtonDisabled = true;
                                                  importanceSliderValue = 50;
                                                  urgencySliderValue = 50;
                                                });
                                              },
                                              icon: Icon(
                                                Icons.send,
                                                color: TooDooColors.success,
                                              ),
                                              tooltip: "Add Task",
                                            ),
                                      hintText: "New Task",
                                      hintStyle:
                                          TextStyle(color: TooDooColors.grey),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          8.0, 8.0, 8.0, 8.0)),
                                  autofocus: true,
                                  onChanged: (String _input) {
                                    updateTextField(state, _input);
                                  },
                                  onSubmitted: (String _inputText) {
                                    if (_inputText != "") {
                                      _addNewNote(_inputText, inputBody);
                                      Navigator.of(context).pop();
                                      setState(() {
                                        inputBody = "";
                                        inputBody = "";
                                        addButtonDisabled = true;
                                        importanceSliderValue = 50;
                                        urgencySliderValue = 50;
                                      });
                                    } else {
                                      Toast.show(
                                        "Write Task",
                                        context,
                                        duration: Toast.LENGTH_SHORT,
                                        gravity: Toast.BOTTOM,
                                        backgroundColor: TooDooColors.none,
                                        textColor: TooDooColors.dark,
                                      );
                                    }
                                  },
                                  textCapitalization: TextCapitalization.words,
                                ),
                                Container(
                                  height: (MediaQuery.of(context).size.height) *
                                      0.2,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: "Add Detail...",
                                      hintStyle:
                                          TextStyle(color: TooDooColors.grey),
                                      contentPadding: EdgeInsets.fromLTRB(
                                          8.0, 0.0, 8.0, 0.0),
                                    ),
                                    onChanged: (String _input) {
                                      setState(() {
                                        inputBody = _input;
                                      });
                                    },
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    maxLines: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(height: 10),
                  ],
                ),
              );
            });
          }
        });
  }

  _sliders(context, state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(18.0, 0.0, 0.0, 0.0),
                child: Text(
                  "Importance",
                  style: TextStyle(color: TooDooColors.grey),
                )),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                valueIndicatorColor: TooDooColors.blue,
                activeTrackColor: TooDooColors.blue,
                activeTickMarkColor: TooDooColors.none,
                inactiveTickMarkColor: TooDooColors.none,
                thumbColor: TooDooColors.blue,
                overlayColor: Colors.blueAccent
                    .withOpacity(0.3), // Custom Thumb overlay Co
              ),
              child: Slider(
                value: importanceSliderValue,
                min: 0,
                max: 100,
                divisions: 100,
                label: importanceSliderValue.toInt().toString() + "%",
                onChanged: (double value) {
                  updateSliders(state, urgencySliderValue, value);
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(18.0, 0.0, 0.0, 0.0),
                child: Text(
                  "Urgency",
                  style: TextStyle(color: TooDooColors.grey),
                )),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                valueIndicatorColor: TooDooColors.failure,
                activeTrackColor: TooDooColors.failure,
                activeTickMarkColor: TooDooColors.none,
                inactiveTickMarkColor: TooDooColors.none,
                thumbColor: TooDooColors.failure,
                overlayColor: Colors.redAccent.withOpacity(0.3),
              ),
              child: Slider(
                value: urgencySliderValue,
                min: 0,
                max: 100,
                divisions: 100,
                label: urgencySliderValue.toInt().toString() + "%",
                onChanged: (double value) {
                  updateSliders(state, value, importanceSliderValue);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // gets the new text onChanged and updated the bottom sheet
  // since setState doesn't work in bottom sheets
  Future<Null> updateTextField(StateSetter updateState, String newInput) async {
    updateState(() {
      if (newInput == "") {
        inputTitle = "";
        addButtonDisabled = true;
      } else {
        inputTitle = newInput;
        addButtonDisabled = false;
      }
    });
  }

  Future<Null> updateSliders(StateSetter updateState, double newUrgencyValue,
      double newImportanceValue) async {
    updateState(() {
      importanceSliderValue = newImportanceValue;
      urgencySliderValue = newUrgencyValue;
    });
  }

  _addNewNote(String title, String body) {
    Note note = Note(
      title: title,
      body: body,
      urgency: urgencySliderValue.toInt(),
      importance: importanceSliderValue.toInt(),
    );
    note.add();
  }
}
