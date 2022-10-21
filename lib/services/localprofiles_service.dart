import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLiteLocalProfiles {
  // -------------------------------------
  // Local Profiles Table
  // -------------------------------------

  static Future<void> createTableProfile(sql.Database database) async {
    //Create localprofiles table (Used to store local logged in profiles)
    await database.execute("""CREATE TABLE localprofiles(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        profileid INT,
        firstname TEXT,
        lastname TEXT,
        email TEXT,
        password TEXT,
        selected TEXT,
        profilecolor TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    //If tables don't exist, create tables
    return sql.openDatabase(
      'alleatlocal.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTableProfile(database);
      },
    );
  }

  //------------------------------------------------------------
  // Profile Creation
  //------------------------------------------------------------

  // Create new profile

  static Future<void> createProfile(dynamic profileid, String firstname,
      String lastname, String email, String password) async {
    //Create profile using firstname, lastname, email and encrypted password
    List colors = [
      "0xff9adedb",
      "0xffaaf0d1",
      "0xffb2fba5",
      "0xffbdb0d0",
      "0xffff9899",
      "0xffffb7ce"
    ];
    Random random = Random();
    String randomProfileColor = colors[random.nextInt(colors.length)];
    final db = await SQLiteLocalProfiles.db();
    db.insert("localprofiles", {
      //Insert data into localprofiles table
      "profileid": profileid,
      "firstname": firstname,
      "lastname": lastname,
      "email": email,
      "password": password,
      "profilecolor": randomProfileColor,
    });
    db.rawUpdate(
        'UPDATE localprofiles SET selected = false'); //Set all profiles selected status to false
    db.rawUpdate(
        'UPDATE localprofiles SET selected = true WHERE email = "$email"');
  }

  //------------------------------------------------------------
  // Profile Query
  //------------------------------------------------------------

  // Get profiles

  static Future<List<Map<String, dynamic>>> getProfiles() async {
    final db = await SQLiteLocalProfiles.db();
    return db.query('localprofiles', orderBy: "id"); //get local profiles
  }

  // Get first profile in profiles table

  static Future<List<Map<String, dynamic>>> getFirstProfile() async {
    final db = await SQLiteLocalProfiles.db();
    return db.rawQuery('SELECT * FROM localprofiles ORDER BY id ASC LIMIT 1');
  }

  // Get currently selected profile color from table

  static Future<List<Map<String, Object?>>> getSelectedProfileColor() async {
    final db = await SQLiteLocalProfiles.db();
    return db.rawQuery(
        'SELECT profilecolor FROM localprofiles ORDER BY id ASC LIMIT 1');
  }

  //------------------------------------------------------------
  // Profile Modify
  //------------------------------------------------------------

  // Update an profile by id
  static Future<void> updateProfile(int id, String firstname, String lastname,
      String email, String password) async {
    //Update profile using firstname, lastname, email and encrypted password
    final db = await SQLiteLocalProfiles.db();

    final data = {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'password': password,
    };

    await db.update('localprofiles', data, where: "id = ?", whereArgs: [id]);
  }

  // Delete profile
  static Future<void> deleteProfile(int id) async {
    //Delete profile associated with the id inputted
    final db = await SQLiteLocalProfiles.db();
    try {
      //Try to delete profile
      await db.delete("localprofiles", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      // If it fails, prints the error to the console
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
