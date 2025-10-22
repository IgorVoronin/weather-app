import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../../services/local_storage.dart';
import '../../services/posts_service.dart';
import '../../services/firestore_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth? _firebaseAuth;
  final LocalStorage _localStorage;
  final PostsService _postsService;
  final FirestoreService _firestoreService;

  AuthBloc({
    FirebaseAuth? firebaseAuth,
    LocalStorage? localStorage,
    PostsService? postsService,
    FirestoreService? firestoreService,
  })  : _firebaseAuth = firebaseAuth,
        _localStorage = localStorage ?? LocalStorage(),
        _postsService = postsService ?? PostsService(),
        _firestoreService = firestoreService ?? FirestoreService(),
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthUpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      if (_firebaseAuth == null) {
        emit(AuthError('Ошибка: Firebase не инициализирован'));
        return;
      }

      UserCredential userCredential;
      try {
        // Попытка входа
        userCredential = await _firebaseAuth!.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
      } catch (e) {
        // Если пользователя нет, регистрируем
        userCredential = await _firebaseAuth!.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
      }

      final firebaseUser = userCredential.user!;
      
      // Проверяем, есть ли профиль в Firestore
      UserModel? user = await _firestoreService.getUser(firebaseUser.uid);
      
      if (user == null) {
        // Создаём новый профиль
        user = UserModel(
          id: firebaseUser.uid,
          name: event.email.split('@')[0],
          email: event.email,
        );
        await _firestoreService.saveUser(user);
      }
      
      // Сохраняем локально для оффлайн-режима
      await _localStorage.saveUser(user.toJson());
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_getErrorMessage(e.toString())));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      if (_firebaseAuth != null) {
        await _firebaseAuth!.signOut();
      }
      await _localStorage.clearUser();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Ошибка выхода: $e'));
    }
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userData = await _localStorage.getUser();
      if (userData != null) {
        final user = UserModel.fromJson(userData);
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onUpdateProfile(
    AuthUpdateProfile event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user;
      
      String? photoUrl = currentUser.photoUrl;
      
      if (event.photoPath != null) {
        // Сохраняем локальный путь к фото
        photoUrl = event.photoPath;
        await _localStorage.savePhoto(event.photoPath!);
      }

      final updatedUser = currentUser.copyWith(
        photoUrl: photoUrl,
        city: event.city ?? currentUser.city,
        name: event.name ?? currentUser.name,
      );

      // Сохраняем в Firestore
      await _firestoreService.saveUser(updatedUser);
      
      // Сохраняем локально
      await _localStorage.saveUser(updatedUser.toJson());
      
      // Обновляем данные пользователя во всех постах и комментариях
      await _postsService.updateUserInPosts(
        updatedUser.id,
        updatedUser.name,
        updatedUser.photoUrl,
      );
      
      emit(AuthAuthenticated(updatedUser));
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'invalid-email':
        return 'Неверный email';
      default:
        return 'Ошибка авторизации';
    }
  }
}
