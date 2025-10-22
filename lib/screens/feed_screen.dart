import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/post_model.dart';
import '../services/posts_service.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import 'user_profile_screen.dart';
import 'post_detail_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostsService _postsService = PostsService();
  List<PostModel> _posts = [];
  List<PostModel> _filteredPosts = [];
  bool _isLoading = true;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    final posts = await _postsService.getPosts();
    setState(() {
      _posts = posts;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    if (_selectedCity == null) {
      _filteredPosts = _posts;
    } else {
      _filteredPosts = _posts.where((post) => post.weather.city == _selectedCity).toList();
    }
  }

  List<String> _getUniqueCities() {
    return _posts.map((post) => post.weather.city).toSet().toList()..sort();
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
    final cities = _getUniqueCities();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Лента'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (cities.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_list,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Город:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: _selectedCity,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(
                                    'Все города',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                ...cities.map((city) => DropdownMenuItem<String?>(
                                      value: city,
                                      child: Text(city),
                                    )),
                              ],
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedCity = value;
                                  _applyFilter();
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadPosts,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = _filteredPosts[index];
                        return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UserProfileScreen(user: post.user),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade700,
                            backgroundImage: post.user.photoUrl != null
                                ? (kIsWeb
                                    ? NetworkImage(post.user.photoUrl!)
                                    : FileImage(File(post.user.photoUrl!)))
                                    as ImageProvider
                                : null,
                            child: post.user.photoUrl == null
                                ? Text(
                                    post.user.name[0].toUpperCase(),
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
                                  post.user.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _formatDate(post.createdAt),
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
                                      post.weather.city,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  post.weather.description,
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
                                  _getWeatherIcon(post.weather.icon),
                                  size: 40,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${post.weather.temperature.toStringAsFixed(1)}°C',
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
                        post.comment,
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          final isAuthenticated = authState is AuthAuthenticated;
                          final currentUserId = isAuthenticated ? authState.user.id : null;
                          final isLiked = currentUserId != null && post.isLikedBy(currentUserId);

                          return Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                ),
                                onPressed: isAuthenticated
                                    ? () async {
                                        await _postsService.toggleLike(post.id, currentUserId!);
                                        _loadPosts();
                                      }
                                    : null,
                                color: isLiked ? Colors.red : Colors.grey.shade600,
                              ),
                              if (post.likesCount > 0)
                                Text(
                                  '${post.likesCount}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(Icons.comment_outlined),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PostDetailScreen(post: post),
                                    ),
                                  );
                                  _loadPosts();
                                },
                                color: Colors.grey.shade600,
                              ),
                              if (post.commentsCount > 0)
                                Text(
                                  '${post.commentsCount}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(Icons.share_outlined),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Функция поделиться скоро появится'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                color: Colors.grey.shade600,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                        ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
