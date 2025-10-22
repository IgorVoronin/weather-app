import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthUpdateProfile extends AuthEvent {
  final String? photoPath;
  final String? city;
  final String? name;

  const AuthUpdateProfile({this.photoPath, this.city, this.name});

  @override
  List<Object?> get props => [photoPath, city, name];
}
