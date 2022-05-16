import 'package:ridetripper/model/contactModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ContactsDatabase {
  static final ContactsDatabase instance = ContactsDatabase._init();

  static Database? _database;
  ContactsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('contacts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbpath = await getDatabasesPath();
    final path = join(dbpath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final realType = 'REAL NOT NULL';

    await db.execute('''
    CREATE TABLE $tableContacts(
      ${ContactsField.id} $idType,
      ${ContactsField.contactName} $textType,
      ${ContactsField.phoneNumber} $textType,
      ${ContactsField.initials} $textType
    )
    ''');
  }

  Future<ContactModel> create(ContactModel contactModel) async {
    final db = await instance.database;
    final id = await db.insert(tableContacts, contactModel.toJson());
    return contactModel.copy(id: id);
  }

  Future<List<ContactModel>> readAllContacts() async{
    final db = await instance.database;
    final orderBy = '${ContactsField.contactName} ASC';
    final result = await db.query(tableContacts, orderBy: orderBy);
    return result.map((json) => ContactModel.fromJson(json)).toList();
  }

  Future<int> delete(int id) async{
    final db = await instance.database;
    return await db.delete(
      tableContacts,
      where: '${ContactsField.id} = ?',
      whereArgs: [id]
    );
  }
  Future deleteAll() async{
      final db = await instance.database;
      await db.delete(tableContacts);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
