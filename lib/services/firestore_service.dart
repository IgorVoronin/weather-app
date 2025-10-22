import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/weather_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Пользователи
  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    
    if (querySnapshot.docs.isNotEmpty) {
      return UserModel.fromJson(querySnapshot.docs.first.data());
    }
    return null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  // Посты
  Future<void> savePost(PostModel post) async {
    // Вручную собираем данные без вложенных объектов
    final postData = {
      'id': post.id,
      'userId': post.user.id,
      'userName': post.user.name,
      'userEmail': post.user.email,
      'userCity': post.user.city,
      'userPhotoUrl': post.user.photoUrl,
      'weatherCity': post.weather.city,
      'weatherTemp': post.weather.temperature,
      'weatherDesc': post.weather.description,
      'weatherIcon': post.weather.icon,
      'weatherFeelsLike': post.weather.feelsLike,
      'weatherHumidity': post.weather.humidity,
      'weatherWindSpeed': post.weather.windSpeed,
      'comment': post.comment,
      'createdAt': post.createdAt.toIso8601String(),
      'likedBy': post.likedBy,
      'comments': post.comments.map((c) => {
        'id': c.id,
        'userId': c.user.id,
        'userName': c.user.name,
        'userEmail': c.user.email,
        'userPhotoUrl': c.user.photoUrl,
        'text': c.text,
        'createdAt': c.createdAt.toIso8601String(),
      }).toList(),
    };
    await _firestore.collection('posts').doc(post.id).set(postData);
  }

  Future<List<PostModel>> getPosts() async {
    final querySnapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();
    
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return _reconstructPost(data);
    }).toList();
  }

  PostModel _reconstructPost(Map<String, dynamic> data) {
    return PostModel(
      id: data['id'],
      user: UserModel(
        id: data['userId'],
        name: data['userName'],
        email: data['userEmail'],
        city: data['userCity'],
        photoUrl: data['userPhotoUrl'],
      ),
      weather: WeatherModel(
        city: data['weatherCity'],
        temperature: data['weatherTemp'],
        description: data['weatherDesc'],
        icon: data['weatherIcon'],
        feelsLike: data['weatherFeelsLike'],
        humidity: data['weatherHumidity'],
        windSpeed: data['weatherWindSpeed'],
      ),
      comment: data['comment'],
      createdAt: DateTime.parse(data['createdAt']),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      comments: (data['comments'] as List? ?? [])
          .map((c) => CommentModel(
                id: c['id'],
                user: UserModel(
                  id: c['userId'],
                  name: c['userName'],
                  email: c['userEmail'],
                  photoUrl: c['userPhotoUrl'],
                ),
                text: c['text'],
                createdAt: DateTime.parse(c['createdAt']),
              ))
          .toList(),
    );
  }

  Stream<List<PostModel>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _reconstructPost(doc.data()))
            .toList());
  }

  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    await _firestore.collection('posts').doc(postId).update(data);
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }
}
