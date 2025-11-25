part of 'auth_bloc.dart';

/// Auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check authentication status
class CheckAuthStatus extends AuthEvent {}

/// Sign in with email
class SignInWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// Sign up with email
class SignUpWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;

  const SignUpWithEmailEvent({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [email, password, fullName, phoneNumber];
}

/// Sign in with Google
class SignInWithGoogleEvent extends AuthEvent {}

/// Sign out
class SignOutEvent extends AuthEvent {}

/// Send password reset
class SendPasswordResetEvent extends AuthEvent {
  final String email;

  const SendPasswordResetEvent(this.email);

  @override
  List<Object> get props => [email];
}

/// Update user profile
class UpdateProfileEvent extends AuthEvent {
  final String fullName;
  final String? phoneNumber;
  final String? photoUrl;

  const UpdateProfileEvent({
    required this.fullName,
    this.phoneNumber,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [fullName, phoneNumber, photoUrl];
}

/// Resend verification email
class ResendVerificationEmailEvent extends AuthEvent {}

/// Check if email has been verified (reload user)
class CheckEmailVerifiedEvent extends AuthEvent {}
