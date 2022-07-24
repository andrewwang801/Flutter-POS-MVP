import '../model/operator_model.dart';

abstract class IOperatorRepository {
  Future<OperatorModel?> getOperators(String pin);
  Future<void> insertOpHistory(int operatorNo);
  Future<void> updateOpHistory(int operatorNo);
  Future<void> checkOpHistory();
  Future<int> countOperatorTable();
}
