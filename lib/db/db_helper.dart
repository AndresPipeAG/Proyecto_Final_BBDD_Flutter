import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'notes.db');

    debugPrint("📂 Ruta de la base de datos: $path");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE contacts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          email TEXT TEXT
        )
      ''');
      },
    );
  }

  Future<int> insertContact(Contact contact) async {
    final database = await db;
    return await database.insert('contacts', contact.toMap());
  }

  Future<List<Contact>> getContacts() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query('contacts');
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  Future<int> updateContact(Contact contact) async {
    final database = await db;
    return await database.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(int id) async {
    final database = await db;
    return await database.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }
}

Future<Contact?> getContactById(int id) async {
  final database = await DBHelper().db;
  final maps = await database.query(
    'contacts',
    where: 'id = ?',
    whereArgs: [id],
    limit: 1,
  );
  if (maps.isEmpty) return null;
  return Contact.fromMap(maps.first);
}

Future<List<Contact>> searchContactsByName(String q) async {
  final database = await DBHelper().db;
  final pattern = '%${q.trim()}%';
  final maps = await database.query(
    'contacts',
    where:
        'name LIKE ? COLLATE NOCASE', // COLLATE NOCASE hace la búsqueda insensible a mayúsculas en SQLite
    whereArgs: [pattern],
  );
  return maps.map((m) => Contact.fromMap(m)).toList();
}

Future<List<Contact>> searchContactsByPhone(String q) async {
  final database = await DBHelper().db;
  final pattern = '%${q.trim()}%';
  final maps = await database.query(
    'contacts',
    where: 'phone LIKE ? COLLATE NOCASE',
    whereArgs: [pattern],
  );
  return maps.map((m) => Contact.fromMap(m)).toList();
}
