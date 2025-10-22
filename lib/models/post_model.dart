import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import 'weather_model.dart';
import 'comment_model.dart';

part 'post_model.g.dart';

@JsonSerializable()
class PostModel {
  final String id;
  final UserModel user;
  final WeatherModel weather;
  final String comment;
  final DateTime createdAt;
  final List<String> likedBy; // Список ID пользователей, которые поставили лайк
  final List<CommentModel> comments; // Список комментариев

  PostModel({
    required this.id,
    required this.user,
    required this.weather,
    required this.comment,
    required this.createdAt,
    this.likedBy = const [],
    this.comments = const [],
  });

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  PostModel copyWith({
    String? id,
    UserModel? user,
    WeatherModel? weather,
    String? comment,
    DateTime? createdAt,
    List<String>? likedBy,
    List<CommentModel>? comments,
  }) {
    return PostModel(
      id: id ?? this.id,
      user: user ?? this.user,
      weather: weather ?? this.weather,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      likedBy: likedBy ?? this.likedBy,
      comments: comments ?? this.comments,
    );
  }

  int get likesCount => likedBy.length;
  int get commentsCount => comments.length;

  bool isLikedBy(String userId) => likedBy.contains(userId);
}
