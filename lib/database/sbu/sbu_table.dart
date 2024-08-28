import 'package:floor/floor.dart';

import 'model_sbu.dart';

@dao
abstract class SBUTable {
  @Query('SELECT * FROM model_sbu WHERE sbu_code = :sbu_code')
  Future<model_sbu?> findSBUById(String sbu_code);

  @Query('SELECT * FROM model_sbu WHERE sbu_name LIKE ?')
  Future<List<model_sbu>> findAllSBUsByName(String sbu_name);

  @Query('SELECT * FROM model_sbu')
  Future<List<model_sbu>> findAllSBUs();

  @insert
  Future<void> insertSBU(model_sbu sbu);

  @insert
  Future<void> insertSBUs(List<model_sbu> sbus);

  @update
  Future<void> updateSBUs(List<model_sbu> sbuk);

  @delete
  Future<void> updateSBU(model_sbu sbu);

  @delete
  Future<void> deleteSBUs(List<model_sbu> sbus);
}
