import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../services/posts_service.dart';
import '../services/firestore_service.dart';
import '../repositories/fake_data_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PostsService _postsService = PostsService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  bool _hasData = false;

  @override
  void initState() {
    super.initState();
    _checkData();
  }

  Future<void> _checkData() async {
    final posts = await _postsService.getPosts();
    if (mounted) {
      setState(() {
        _hasData = posts.isNotEmpty;
      });
    }
  }

  Future<void> _loadTestData() async {
    setState(() => _isLoading = true);
    
    try {
      // Загружаем пользователей
      final fakeUsers = FakeDataRepository.getFakeUsers();
      for (final user in fakeUsers) {
        await _firestoreService.saveUser(user);
      }

      // Загружаем посты
      final fakePosts = FakeDataRepository.getFakePosts();
      for (final post in fakePosts) {
        await _firestoreService.savePost(post);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasData = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Тестовые данные загружены!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: Text('Пользователь не авторизован'));
          }

          final user = state.user;

          return ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade400, Colors.blue.shade700],
                  ),
                ),
                child: Column(
                  children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: user.photoUrl != null
                        ? (kIsWeb
                            ? NetworkImage(user.photoUrl!)
                            : FileImage(File(user.photoUrl!)))
                            as ImageProvider
                        : null,
                    child: user.photoUrl == null
                        ? Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.blue.shade700,
                          )
                        : null,
                  ),
                    const SizedBox(height: 12),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'ПРИЛОЖЕНИЕ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language, color: Colors.blue),
                      title: const Text('Язык'),
                      subtitle: const Text('Русский'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Функция скоро появится'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications, color: Colors.blue),
                      title: const Text('Уведомления'),
                      subtitle: const Text('Настройка уведомлений'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Функция скоро появится'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.blue),
                      title: const Text('О приложении'),
                      subtitle: const Text('Версия 1.0.0'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Weather App',
                          applicationVersion: '1.0.0',
                          applicationIcon: const Icon(
                            Icons.cloud,
                            size: 48,
                            color: Colors.blue,
                          ),
                          children: const [
                            Text(
                              'Приложение для отслеживания погоды и обмена впечатлениями о ней с другими пользователями.',
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (!_hasData) ...[
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'ДАННЫЕ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    leading: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_download, color: Colors.blue),
                    title: const Text('Загрузить тестовые данные'),
                    subtitle: const Text('Добавить примеры постов'),
                    trailing: _isLoading ? null : const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _isLoading ? null : _loadTestData,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'АККАУНТ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Выйти из аккаунта',
                    style: TextStyle(color: Colors.red),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showLogoutDialog(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
