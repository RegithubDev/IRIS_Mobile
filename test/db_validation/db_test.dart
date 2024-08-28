@TestOn('vm')
library sqflite_common_ffi.test.sqflite_ffi_doc_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Init ffi loader if needed.
  sqfliteFfiInit();
  group('Database Testing', () {

    test('SBU table test', () async {
      var factory = databaseFactoryFfi;
      var db = await factory.openDatabase(inMemoryDatabasePath,
          options: OpenDatabaseOptions(
              version: 1,
              onCreate: (db, version) async {
                await db.execute(
                    'CREATE TABLE IF NOT EXISTS `model_sbu` (`sbu_code` TEXT NOT NULL,`sbu_name` TEXT NOT NULL)');
              }));
      // Insert some data
      await db.insert('model_sbu', {'sbu_code': 'CO','sbu_name': 'Corporate Office'});

      // Check content
      expect(await db.query('model_sbu'), [{'sbu_code': 'CO', 'sbu_name': 'Corporate Office'}]);

      await db.close();
    });

    test('Department table test', () async {
      var factory = databaseFactoryFfi;
      var db = await factory.openDatabase(inMemoryDatabasePath,
          options: OpenDatabaseOptions(
              version: 1,
              onCreate: (db, version) async {
                await db.execute(
                    'CREATE TABLE IF NOT EXISTS `model_department` (`department_code` TEXT NOT NULL,`department_name` TEXT NOT NULL)');
              }));
      // Insert some data
      await db.insert('model_department', {'department_code': 'Admin','department_name': 'Admin'});

      // Check content
      expect(await db.query('model_department'), [{'department_code': 'Admin', 'department_name': 'Admin'}]);

      await db.close();
    });

    test('Project table test', () async {
      var factory = databaseFactoryFfi;
      var db = await factory.openDatabase(inMemoryDatabasePath,
          options: OpenDatabaseOptions(
              version: 1,
              onCreate: (db, version) async {
                await db.execute(
                    'CREATE TABLE IF NOT EXISTS `model_project` (`project_code` TEXT NOT NULL,`project_name` TEXT NOT NULL)');
              }));
      // Insert some data
      await db.insert('model_project', {'project_code': 'CO','project_name': 'Corporate Office'});

      // Check content
      expect(await db.query('model_project'), [{'project_code': 'CO', 'project_name': 'Corporate Office'}]);

      await db.close();
    });

    test('User table test', () async {
      var factory = databaseFactoryFfi;
      var db = await factory.openDatabase(inMemoryDatabasePath,
          options: OpenDatabaseOptions(
              version: 1,
              onCreate: (db, version) async {
                await db.execute(
                    'CREATE TABLE IF NOT EXISTS `model_user` (`user_id` TEXT NOT NULL,`user_name` TEXT NOT NULL)');
              }));
      // Insert some data
      await db.insert('model_user', {'user_id': '22007871','user_name': 'A Amarnadha reddy'});

      // Check content
      expect(await db.query('model_user'), [{'user_id': '22007871', 'user_name': 'A Amarnadha reddy'}]);

      await db.close();
    });

  });


}