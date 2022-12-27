// ignore_for_file: depend_on_referenced_packages

import 'package:plan_list_demo_sqflite/models/plan_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _databaseService = DatabaseService._internal();
  factory DatabaseService() => _databaseService;
  DatabaseService._internal();
  static String planItemTable = 'Plans';

  static Database? _database;
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Database get db => DatabaseService._database!;

  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'localDb.db');
    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $planItemTable(id INTEGER PRIMARY KEY, planDuration TEXT, planType TEXT)',
    );
  }

  static Future<void> insertPlan(PlanItem planItem) async {
    await db.insert(
      planItemTable,
      planItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<PlanItem>> plans() async {
    final List<Map<String, dynamic>> maps = await db.query(planItemTable);
    return List.generate(maps.length, (index) => PlanItem.fromMap(maps[index]));
  }

  //* find one record;

  static Future<PlanItem> plan(int id) async {
    final List<Map<String, dynamic>> maps =
        await db.query(planItemTable, where: 'id = ?', whereArgs: [id]);
    return PlanItem.fromMap(maps[0]);
  }

  static Future<void> updatePlan(PlanItem planItem) async {
    await db.update(
      planItemTable,
      planItem.toMap(),
      where: 'id = ?',
      whereArgs: [planItem.id],
    );
  }

  static Future<void> deletePlan(int id) async {
    await db.delete(
      planItemTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteAllPlans() async {
    await db.delete(planItemTable);
  }
}
