import 'dart:async';

import 'package:floor/floor.dart';
import 'package:resus_test/database/sbu/model_sbu.dart';
import 'package:resus_test/database/sbu/sbu_table.dart';
import 'package:resus_test/database/themes/model_themes.dart';
import 'package:resus_test/database/themes/themes_table.dart';
import 'package:resus_test/database/user/user_table.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'department/department_table.dart';
import 'department/model_department.dart';
import 'project/model_project.dart';
import 'project/project_table.dart';
import 'user/model_user.dart';

part 'database.g.dart';

@Database(version: 1, entities: [model_department, model_project, model_user])
abstract class FlutterDatabase extends FloorDatabase {
  DepartmentTable get modelDepartment;

  ProjectTable get modelProject;

  SBUTable get modelSBU;

  UserTable get modelUser;

  ThemesTable get modelThemes;


}
