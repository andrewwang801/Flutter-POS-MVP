import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'prep_model.g.dart';

@injectable
@JsonSerializable()
class PrepModel extends Equatable {
  final String? number;
  final String? name;
  int? quantity;

  PrepModel(this.number, this.name);

  factory PrepModel.fromJson(Map<String, dynamic> json) =>
      _$PrepModelFromJson(json);
  Map<String, dynamic> toJson() => _$PrepModelToJson(this);
  @override
  List<Object?> get props => [this.number];
}
