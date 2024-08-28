import 'package:floor/floor.dart';

import 'model_user.dart';

@dao
abstract class UserTable {
  @Query('SELECT * FROM model_user WHERE user_id = :user_id')
  Future<model_user?> findUserById(String user_id);

  @Query('SELECT * FROM model_user WHERE user_id LIKE ?')
  Future<List<model_user>> findAllUsersByName(String user_id);

  @Query('SELECT * FROM model_user')
  Future<List<model_user>> findAllUsers();

  @insert
  Future<void> insertUser(model_user user);

  @insert
  Future<void> insertUsers(List<model_user> users);

  @update
  Future<void> updateUsers(List<model_user> user);

  @delete
  Future<void> updateUser(model_user user);

  @delete
  Future<void> deleteUsers(List<model_user> users);
}
