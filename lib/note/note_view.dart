import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:toodoo/note/note_model.dart';
import 'package:toodoo/style/toodoo_styles.dart';

class NoteView extends StatefulWidget {
  final NoteList noteList;
  final int index;
  final int id;

  NoteView({Key key, @required this.noteList, this.index, this.id})
      : super(key: key);

  @override
  _NoteViewState createState() => _NoteViewState(
        this.noteList.notes[this.index].title,
        this.noteList.notes[this.index].body,
      );
}

class _NoteViewState extends State<NoteView> {
  String defaultTitle;
  String defaultBody;
  bool updateButtonDisabled = true;

  _NoteViewState(this.defaultTitle, this.defaultBody);

  @override
  Widget build(BuildContext context) {
    return SwipeDetector(
      onSwipeRight: () {
        Navigator.pop(context, true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Your Task"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context, true),
          ),
          shadowColor: TooDooColors.none,
          backgroundColor: TooDooColors.none,
          iconTheme: IconThemeData(opacity: 0.8, color: TooDooColors.darkGrey),
        ),
        body: ListView(
          children: [
            Container(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 23.0, 10.0, 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: (MediaQuery.of(context).size.width) * 0.45,
                              child: Column(
                                children: [
                                  Text(
                                    "Urgency",
                                    style:
                                        TextStyle(color: TooDooColors.darkGrey),
                                  ),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      valueIndicatorColor: TooDooColors.failure,
                                      activeTrackColor: TooDooColors.failure,
                                      activeTickMarkColor: TooDooColors.none,
                                      inactiveTickMarkColor: TooDooColors.none,
                                      thumbColor: TooDooColors.failure,
                                      overlayColor:
                                          Colors.redAccent.withOpacity(0.3),
                                    ),
                                    child: Slider(
                                      value: this
                                          .widget
                                          .noteList
                                          .notes[this.widget.index]
                                          .urgency
                                          .toDouble(),
                                      min: 0,
                                      max: 100,
                                      divisions: 10,
                                      onChanged: (double value) {},
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: (MediaQuery.of(context).size.width) * 0.45,
                              child: Column(
                                children: [
                                  Text(
                                    "Importance",
                                    style:
                                        TextStyle(color: TooDooColors.darkGrey),
                                  ),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      valueIndicatorColor: TooDooColors.success,
                                      activeTrackColor: TooDooColors.success,
                                      thumbColor: TooDooColors.success,
                                      activeTickMarkColor: TooDooColors.none,
                                      inactiveTickMarkColor: TooDooColors.none,
                                      overlayColor: Colors.greenAccent
                                          .withOpacity(
                                              0.3), // Custom Thumb overlay Co
                                    ),
                                    child: Slider(
                                      value: this
                                          .widget
                                          .noteList
                                          .notes[this.widget.index]
                                          .importance
                                          .toDouble(),
                                      min: 0,
                                      max: 100,
                                      divisions: 10,
                                      onChanged: (double value) {},
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Task",
                          style: TextStyle(color: TooDooColors.grey),
                        ),
                        TextFormField(
                          initialValue:
                              "${this.widget.noteList.notes[this.widget.index].title}",
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          onChanged: (input) {
                            // if only there is an update to the text
                            if (input != defaultTitle) {
                              setState(() {
                                defaultTitle = input;
                              });

                              if (defaultTitle != "") {
                                Note note = Note(
                                    title: defaultTitle,
                                    body: defaultBody,
                                    id: this
                                        .widget
                                        .noteList
                                        .notes[this.widget.index]
                                        .id);
                                note.update();
                              }
                            } else {
                              setState(() {});
                            }
                          },
                          textCapitalization: TextCapitalization.words,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Detail",
                          style: TextStyle(
                            color: TooDooColors.grey,
                          ),
                        ),
                        Container(
                          // height: (MediaQuery.of(context).size.height)*0.6,
                          height: 500.0,
                          child: TextFormField(
                            initialValue:
                                "${this.widget.noteList.notes[this.widget.index].body}",
                            style: TextStyle(
                                fontSize: 16.0, fontStyle: FontStyle.normal),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                            maxLines: 10,
                            onChanged: (input) {
                              if (input != defaultBody) {
                                setState(() {
                                  defaultBody = input;
                                });

                                Note note = Note(
                                    title: defaultTitle,
                                    body: defaultBody,
                                    id: this
                                        .widget
                                        .noteList
                                        .notes[this.widget.index]
                                        .id);
                                note.update();
                              } else {
                                setState(() {});
                              }
                            },
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(
                  Icons.check,
                  color: TooDooColors.success,
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              label: 'Update',
            ),
            BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(
                  Icons.radio_button_unchecked,
                  color: TooDooColors.grey,
                ),
                onPressed: () {
                  Note note = Note(
                    id: this.widget.id,
                    title: "",
                    body: "",
                    completed: 0,
                  );
                  note.complete();
                  Navigator.pop(context, true);
                },
              ),
              label: 'Mark as Done',
            ),
            BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(
                  Icons.delete_forever_sharp,
                  color: TooDooColors.failure,
                ),
                onPressed: () {
                  Note note = Note(
                    id: this.widget.id,
                    title: "",
                    body: "",
                    completed: 0,
                  );
                  note.delete();
                  Navigator.pop(context, true);
                },
              ),
              label: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
