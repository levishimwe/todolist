import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:savesmart/core/usecase/usecase.dart';
import 'package:savesmart/features/auth/domain/entities/user.dart';
import 'package:savesmart/features/auth/domain/usecases/get_current_user.dart';
import 'package:savesmart/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:savesmart/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:savesmart/features/auth/domain/usecases/sign_out.dart';
import 'package:savesmart/features/auth/domain/usecases/sign_up_with_email.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final auth.FirebaseAuth firebaseAuth;

  AuthBloc({
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signInWithGoogle,
    required this.signOut,
    required this.getCurrentUser,
    required this.firebaseAuth,
  }) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);
    on<ResendVerificationEmailEvent>(_onResendVerificationEmail);
    on<CheckEmailVerifiedEvent>(_onCheckEmailVerified);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await getCurrentUser(NoParams());

    result.fold((failure) => emit(Unauthenticated()), (user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await signInWithEmail(
      SignInParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        // For login, we don't require verification - user may have verified previously
        // They can access the app even if not verified (optional: add check if needed)
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await signUpWithEmail(
      SignUpParams(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        phoneNumber: event.phoneNumber,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) async {
        // Newly signed up user must verify email first
        final current = firebaseAuth.currentUser;
        if (current != null && !current.emailVerified) {
          // Ensure verification email sent
          try {
            await current.sendEmailVerification();
          } catch (_) {}
          emit(EmailVerificationPending(user.email));
        } else {
          emit(Authenticated(user));
        }
      },
    );
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await signInWithGoogle(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await signOut(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> _onResendVerificationEmail(
    ResendVerificationEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    final current = firebaseAuth.currentUser;
    if (current != null && !current.emailVerified) {
      try {
        await current.sendEmailVerification();
        emit(EmailVerificationPending(current.email!));
      } catch (e) {
        emit(AuthError('Failed to resend verification email: $e'));
      }
    }
  }

  Future<void> _onCheckEmailVerified(
    CheckEmailVerifiedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final current = firebaseAuth.currentUser;
    if (current != null) {
      try {
        await current.reload();
        final refreshed = firebaseAuth.currentUser;
        
        if (refreshed != null && refreshed.emailVerified) {
          // Email is verified! Fetch full user data
          final result = await getCurrentUser(NoParams());
          result.fold(
            (failure) => emit(AuthError('Failed to load user data: ${failure.message}')),
            (user) {
              if (user != null) {
                emit(Authenticated(user));
              } else {
                emit(AuthError('User data not found'));
              }
            },
          );
        } else {
          // Still not verified
          emit(const AuthError('Email not verified yet. Please check your email and click the verification link.'));
          // Go back to verification pending state
          await Future.delayed(const Duration(seconds: 2));
          emit(EmailVerificationPending(refreshed?.email ?? ''));
        }
      } catch (e) {
        emit(AuthError('Failed to check verification status: $e'));
        await Future.delayed(const Duration(seconds: 2));
        emit(EmailVerificationPending(current.email ?? ''));
      }
    } else {
      emit(const AuthError('No user logged in'));
    }
  }
}
