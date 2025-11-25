part of 'auth_bloc.dart';

/// Auth states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {}

/// Loading state
class AuthLoading extends AuthState {}

/// Authenticated state
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// Unauthenticated state
class Unauthenticated extends AuthState {}

/// Password reset sent state
class PasswordResetSent extends AuthState {}

/// Profile updated state
class ProfileUpdated extends AuthState {
  final User user;

  const ProfileUpdated(this.user);

  @override
  List<Object> get props => [user];
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

/// Email verification pending state
class EmailVerificationPending extends AuthState {
  final String email;

  const EmailVerificationPending(this.email);

  @override
  List<Object> get props => [email];
}
