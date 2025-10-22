import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  final String id;
  final UserModel user;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.user,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);
}
