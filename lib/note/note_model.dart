import 'package:flutter/cupertino.dart';
import 'package:toodoo/db/db_manager.dart';
import 'package:sqflite/sqflite.dart';

class Note {
  int id;
  int completed;
  int urgency;
  int importance;
  final String title;
  final String body;

  Note(
      {this.id = 0,
      this.completed = 0,
      this.title,
      this.body,
      this.urgency,
      this.importance});

  add() async {
    Database db = await DatabaseHelper.instance.database;
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnTitle: this.title,
      DatabaseHelper.columnBody: this.body,
      DatabaseHelper.columnCompleted: this.completed,
      DatabaseHelper.columnUrgency: this.urgency,
      DatabaseHelper.columnImportance: this.importance,
    };

    int result = await db.insert(DatabaseHelper.table, row);
  }

  delete() async {
    Database db = await DatabaseHelper.instance.database;
    int result =
        await db.rawDelete("DELETE FROM toodoo WHERE _id = ?", [this.id]);
  }

  static deleteCompleted() async {
    Database db = await DatabaseHelper.instance.database;
    int result = await db.rawDelete("DELETE FROM toodoo WHERE completed = 1");
  }

  static deleteAll() async {
    Database db = await DatabaseHelper.instance.database;
    int result = await db.rawDelete("DELETE FROM toodoo");
  }

  static fetch(String sortingMethod) async {
    Database db = await DatabaseHelper.instance.database;
    if (sortingMethod == "id") {
      var data = await db
          .rawQuery("SELECT * FROM toodoo ORDER BY completed ASC, _id DESC");
      return data;
    } else if (sortingMethod == "idDesc") {
      var data = await db
          .rawQuery("SELECT * FROM toodoo ORDER BY completed ASC, _id ASC");
      return data;
    }else if (sortingMethod == "importanceAsc") {
      var data = await db.rawQuery(
          "SELECT * FROM toodoo ORDER BY completed ASC, importance ASC");
      return data;
    } else if (sortingMethod == "importanceDesc") {
      var data = await db.rawQuery(
          "SELECT * FROM toodoo ORDER BY completed ASC, importance DESC");
      return data;
    } else if (sortingMethod == "urgencyAsc") {
      var data = await db.rawQuery(
          "SELECT * FROM toodoo ORDER BY completed ASC, urgency ASC");
      return data;
    } else if (sortingMethod == "urgencyDesc") {
      var data = await db.rawQuery(
          "SELECT * FROM toodoo ORDER BY completed ASC, urgency DESC");
      return data;
    }
  }

  update() async {
    Database db = await DatabaseHelper.instance.database;
    // TODO implemet updating i/u sliders
    Map<String, dynamic> values = {
      DatabaseHelper.columnTitle: this.title,
      DatabaseHelper.columnBody: this.body,
    };
    int result = await db.update(DatabaseHelper.table, values,
        where: '${DatabaseHelper.columnId} = ?', whereArgs: [this.id]);
  }

  // this basically means update completed variable to true
  complete() async {
    Database db = await DatabaseHelper.instance.database;
    Map<String, dynamic> values = {
      DatabaseHelper.columnCompleted: 1,
    };
    int result = await db.update(DatabaseHelper.table, values,
        where: '${DatabaseHelper.columnId} = ?', whereArgs: [this.id]);
  }

  // this will reverse completed task
  undone() async {
    Database db = await DatabaseHelper.instance.database;
    Map<String, dynamic> values = {
      DatabaseHelper.columnCompleted: 0,
    };
    int result = await db.update(DatabaseHelper.table, values,
        where: '${DatabaseHelper.columnId} = ?', whereArgs: [this.id]);
  }

  factory Note.fromJson(Map<String, dynamic> data) {
    return Note(
        id: data["_id"],
        title: data["title"],
        body: data["body"],
        completed: data["completed"],
        urgency: data["urgency"],
        importance: data["importance"]);
  }
}

class NoteList {
  final List<Note> notes;

  NoteList({this.notes});

  // this method retrieves list of map of notes and returns
  // a list of Note class which can be accessed by their attributes
  factory NoteList.fromJson(List<Map<String, dynamic>> listOfMapsOfNotes) {
    List<Note> notes = List<Note>();
    notes = listOfMapsOfNotes.map((i) => Note.fromJson(i)).toList();
    return NoteList(notes: notes);
  }
}
