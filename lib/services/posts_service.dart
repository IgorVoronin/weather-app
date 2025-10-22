import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../repositories/fake_data_repository.dart';
import 'local_storage.dart';
import 'firestore_service.dart';

class PostsService {
  static final PostsService _instance = PostsService._internal();
  factory PostsService() => _instance;
  PostsService._internal();

  final FirestoreService _firestoreService = FirestoreService();
  final LocalStorage _localStorage = LocalStorage();
  bool _initialized = false;

  Future<List<PostModel>> getPosts() async {
    if (!_initialized) {
      // Загружаем посты из Firestore
      final posts = await _firestoreService.getPosts();
      
      if (posts.isEmpty) {
        // Если в Firestore пусто, загружаем фейковые данные
        final fakePosts = FakeDataRepository.getFakePosts();
        for (final post in fakePosts) {
          await _firestoreService.savePost(post);
        }
        _initialized = true;
        return fakePosts;
      }
      
      _initialized = true;
      return posts;
    }
    return await _firestoreService.getPosts();
  }

  Stream<List<PostModel>> getPostsStream() {
    return _firestoreService.getPostsStream();
  }

  Future<void> addPost(PostModel post) async {
    await _firestoreService.savePost(post);
  }

  Future<void> toggleLike(String postId, String userId) async {
    final posts = await _firestoreService.getPosts();
    final post = posts.firstWhere((p) => p.id == postId);
    
    final likedBy = List<String>.from(post.likedBy);
    if (likedBy.contains(userId)) {
      likedBy.remove(userId);
    } else {
      likedBy.add(userId);
    }

    await _firestoreService.updatePost(postId, {'likedBy': likedBy});
  }

  Future<void> addComment(String postId, CommentModel comment) async {
    final posts = await _firestoreService.getPosts();
    final post = posts.firstWhere((p) => p.id == postId);
    
    final comments = List<CommentModel>.from(post.comments);
    comments.add(comment);

    // Конвертируем комментарии в плоский формат
    final commentsData = comments.map((c) => {
      'id': c.id,
      'userId': c.user.id,
      'userName': c.user.name,
      'userEmail': c.user.email,
      'userPhotoUrl': c.user.photoUrl,
      'text': c.text,
      'createdAt': c.createdAt.toIso8601String(),
    }).toList();

    await _firestoreService.updatePost(postId, {'comments': commentsData});
  }

  Future<void> updateUserInPosts(String userId, String newName, String? newPhotoUrl) async {
    final posts = await _firestoreService.getPosts();

    for (final post in posts) {
      bool needsUpdate = false;
      PostModel updatedPost = post;
      
      // Обновляем автора поста
      if (post.user.id == userId) {
        final updatedUser = post.user.copyWith(
          name: newName,
          photoUrl: newPhotoUrl,
        );
        updatedPost = updatedPost.copyWith(user: updatedUser);
        needsUpdate = true;
      }

      // Обновляем авторов комментариев
      if (post.comments.any((comment) => comment.user.id == userId)) {
        final updatedComments = post.comments.map((comment) {
          if (comment.user.id == userId) {
            final updatedUser = comment.user.copyWith(
              name: newName,
              photoUrl: newPhotoUrl,
            );
            return CommentModel(
              id: comment.id,
              user: updatedUser,
              text: comment.text,
              createdAt: comment.createdAt,
            );
          }
          return comment;
        }).toList();

        updatedPost = updatedPost.copyWith(comments: updatedComments);
        needsUpdate = true;
      }

      if (needsUpdate) {
        await _firestoreService.savePost(updatedPost);
      }
    }
  }
}
