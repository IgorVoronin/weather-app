// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
  id: json['id'] as String,
  user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  weather: WeatherModel.fromJson(json['weather'] as Map<String, dynamic>),
  comment: json['comment'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  likedBy:
      (json['likedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
  'id': instance.id,
  'user': instance.user,
  'weather': instance.weather,
  'comment': instance.comment,
  'createdAt': instance.createdAt.toIso8601String(),
  'likedBy': instance.likedBy,
  'comments': instance.comments,
};
