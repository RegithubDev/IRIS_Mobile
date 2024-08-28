import 'package:floor/floor.dart';
import 'package:resus_test/database/project/model_project.dart';

@dao
abstract class ProjectTable {
  @Query('SELECT * FROM model_project WHERE WHERE project_code = :project_code')
  Future<model_project?> findProjectById(String project_code);

  @Query('SELECT * FROM model_project WHERE project_name LIKE ?')
  Future<List<model_project>> findAllProjectsByName(String project_name);

  @Query('SELECT * FROM model_project')
  Future<List<model_project>> findAllProjects();

  @insert
  Future<void> insertProject(model_project project);

  @insert
  Future<void> insertProjects(List<model_project> projects);

  @update
  Future<void> updateProjects(List<model_project> project);

  @delete
  Future<void> updateProject(model_project project);

  @delete
  Future<void> deleteProjects(List<model_project> projects);


}
