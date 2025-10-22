import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/posts_service.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostsService _postsService = PostsService();
  final TextEditingController _commentController = TextEditingController();
  late PostModel _currentPost;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _loadPost();
  }

  Future<void> _loadPost() async {
    final posts = await _postsService.getPosts();
    final post = posts.firstWhere((p) => p.id == widget.post.id);
    setState(() => _currentPost = post);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoading = true);

    final comment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      user: authState.user,
      text: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    await _postsService.addComment(_currentPost.id, comment);
    _commentController.clear();

    await _loadPost();
    setState(() => _isLoading = false);

    if (mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 1) {
      return '${difference.inMinutes} минут назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} часов назад';
    } else {
      return DateFormat('dd.MM.yyyy HH:mm').format(date);
    }
  }

  IconData _getWeatherIcon(String iconCode) {
    if (iconCode.startsWith('01')) return Icons.wb_sunny;
    if (iconCode.startsWith('02')) return Icons.wb_cloudy;
    if (iconCode.startsWith('03') || iconCode.startsWith('04')) {
      return Icons.cloud;
    }
    if (iconCode.startsWith('09') || iconCode.startsWith('10')) {
      return Icons.umbrella;
    }
    if (iconCode.startsWith('11')) return Icons.flash_on;
    if (iconCode.startsWith('13')) return Icons.ac_unit;
    return Icons.cloud;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пост'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Пост
                  Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue.shade700,
                                backgroundImage: _currentPost.user.photoUrl != null
                                    ? (kIsWeb
                                        ? NetworkImage(_currentPost.user.photoUrl!)
                                        : FileImage(File(_currentPost.user.photoUrl!)))
                                        as ImageProvider
                                    : null,
                                child: _currentPost.user.photoUrl == null
                                    ? Text(
                                        _currentPost.user.name[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentPost.user.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(_currentPost.createdAt),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue.shade50,
                                  Colors.blue.shade100,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _currentPost.weather.city,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _currentPost.weather.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Icon(
                                      _getWeatherIcon(_currentPost.weather.icon),
                                      size: 40,
                                      color: Colors.orange.shade700,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_currentPost.weather.temperature.toStringAsFixed(1)}°C',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentPost.comment,
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.favorite, color: Colors.red, size: 20),
                              const SizedBox(width: 4),
                              Text('${_currentPost.likesCount}'),
                              const SizedBox(width: 16),
                              Icon(Icons.comment, color: Colors.grey.shade600, size: 20),
                              const SizedBox(width: 4),
                              Text('${_currentPost.commentsCount}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Комментарии
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Комментарии (${_currentPost.commentsCount})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_currentPost.comments.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                'Пока нет комментариев',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else
                          ..._currentPost.comments.map((comment) => Card(
                                margin: const EdgeInsets.only(bottom: 8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.blue.shade700,
                                        backgroundImage: comment.user.photoUrl != null
                                            ? (kIsWeb
                                                ? NetworkImage(comment.user.photoUrl!)
                                                : FileImage(File(comment.user.photoUrl!)))
                                                as ImageProvider
                                            : null,
                                        child: comment.user.photoUrl == null
                                            ? Text(
                                                comment.user.name[0].toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  comment.user.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  _formatDate(comment.createdAt),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(comment.text),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Поле ввода комментария
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is! AuthAuthenticated) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Text('Войдите, чтобы оставить комментарий'),
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Добавить комментарий...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _addComment(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _isLoading
                        ? const SizedBox(
                            width: 40,
                            height: 40,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _addComment,
                            color: Colors.blue.shade700,
                          ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
