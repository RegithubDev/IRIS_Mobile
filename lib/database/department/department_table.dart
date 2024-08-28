import 'package:floor/floor.dart';

import 'model_department.dart';

@dao
abstract class DepartmentTable {
  @Query(
      'SELECT * FROM model_department WHERE department_code = :department_code')
  Future<model_department?> findDepartmentById(String department_code);

  @Query('SELECT * FROM model_department WHERE department_name LIKE ?')
  Future<List<model_department>> findAllDepartmentByName(
      String department_name);

  @Query('SELECT * FROM model_department')
  Future<List<model_department>> findAllDepartments();

  @insert
  Future<void> insertDepartment(model_department dept);

  @insert
  Future<void> insertDepartments(List<model_department> dept);

  @update
  Future<void> updateDepartments(List<model_department> dept);

  @delete
  Future<void> updateDepartment(model_department dept);

  @delete
  Future<void> deleteDepartments(List<model_department> dept);
}
