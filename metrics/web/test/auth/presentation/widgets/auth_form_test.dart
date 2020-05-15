import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/auth/domain/entities/auth_error_code.dart';
import 'package:metrics/auth/presentation/model/auth_error_message.dart';
import 'package:metrics/auth/presentation/model/email_validation_error_message.dart';
import 'package:metrics/auth/presentation/model/password_validation_error_message.dart';
import 'package:metrics/auth/presentation/state/auth_notifier.dart';
import 'package:metrics/auth/presentation/strings/auth_strings.dart';
import 'package:metrics/auth/presentation/widgets/auth_form.dart';
import 'package:metrics/auth/presentation/widgets/auth_input_field.dart';
import 'package:mockito/mockito.dart';

import '../../../test_utils/auth_notifier_mock.dart';
import '../../../test_utils/test_injection_container.dart';
import '../state/auth_notifier_test.dart';

void main() {
  final emailInputFinder =
      find.widgetWithText(AuthInputField, AuthStrings.email);
  final passwordInputFinder =
      find.widgetWithText(AuthInputField, AuthStrings.password);
  final submitButtonFinder =
      find.widgetWithText(RaisedButton, AuthStrings.signIn);

  const testEmail = 'test@email.com';
  const testPassword = 'testPassword';

  final signInUseCase = SignInUseCaseMock();
  final signOutUseCase = SignOutUseCaseMock();
  final receiveAuthUpdates = ReceiveAuthenticationUpdatesMock();

  group("AuthForm", () {
    testWidgets(
      "email input shows an error message if a value is empty",
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _AuthFormTestbed(
            authNotifier: AuthNotifier(
              receiveAuthUpdates,
              signInUseCase,
              signOutUseCase,
            ),
          ),
        );

        await tester.tap(submitButtonFinder);
        await tester.pumpAndSettle();

        expect(
          find.text(AuthStrings.requiredEmailErrorMessage),
          findsOneWidget,
        );
      },
    );

    testWidgets(
        "email input shows an error message if a value is not a valid email",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _AuthFormTestbed(
          authNotifier: AuthNotifier(
            receiveAuthUpdates,
            signInUseCase,
            signOutUseCase,
          ),
        ),
      );
      await tester.enterText(emailInputFinder, 'notAnEmail');

      await tester.tap(submitButtonFinder);
      await tester.pump();

      expect(find.text(AuthStrings.invalidEmailErrorMessage), findsOneWidget);
    });

    testWidgets("password input shows an error message if a value is empty",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _AuthFormTestbed(
          authNotifier: AuthNotifier(
            receiveAuthUpdates,
            signInUseCase,
            signOutUseCase,
          ),
        ),
      );

      await tester.tap(submitButtonFinder);
      await tester.pump();

      expect(
          find.text(AuthStrings.requiredPasswordErrorMessage), findsOneWidget);
    });

    testWidgets(
        "signInWithEmailAndPassword method is called on tap on sign in button",
        (WidgetTester tester) async {
      final authNotifier = AuthNotifierMock();

      await tester.pumpWidget(_AuthFormTestbed(authNotifier: authNotifier));
      await tester.enterText(emailInputFinder, testEmail);
      await tester.enterText(passwordInputFinder, testPassword);
      await tester.tap(submitButtonFinder);

      verify(authNotifier.signInWithEmailAndPassword(testEmail, testPassword))
          .called(equals(1));
    });

    testWidgets("shows an auth error text if the login process went wrong",
        (WidgetTester tester) async {
      await tester.pumpWidget(_AuthFormTestbed(
        authNotifier: SignInErrorAuthNotifierStub(),
      ));
      await tester.enterText(emailInputFinder, 'test@email.com');
      await tester.enterText(passwordInputFinder, 'testPassword');
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      expect(
        find.text(SignInErrorAuthNotifierStub.errorMessage.message),
        findsOneWidget,
      );
    });
  });
}

/// A testbed widget, used to test the [AuthForm] widget.
class _AuthFormTestbed extends StatelessWidget {
  final AuthNotifier authNotifier;

  /// Creates the [_AuthFormTestbed] with the given [authNotifier].
  const _AuthFormTestbed({
    this.authNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return TestInjectionContainer(
      authNotifier: authNotifier,
      child: MaterialApp(
        home: Scaffold(
          body: AuthForm(),
        ),
      ),
    );
  }
}

/// Stub of the [AuthNotifier] that emulates presence of auth message error.
class SignInErrorAuthNotifierStub extends ChangeNotifier
    implements AuthNotifier {
  static const errorMessage = AuthErrorMessage(AuthErrorCode.unknown);

  @override
  bool get isLoggedIn => false;

  @override
  AuthErrorMessage get authErrorMessage => _authExceptionDescription;

  /// Contains text description of any authentication exception that may occur.
  AuthErrorMessage _authExceptionDescription;

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _authExceptionDescription = errorMessage;
    notifyListeners();
  }

  @override
  void subscribeToAuthenticationUpdates() {}

  @override
  Future<void> signOut() async {}

  @override
  void validateEmail(String value) {}

  @override
  void validatePassword(String value) {}

  @override
  EmailValidationErrorMessage get emailValidationErrorMessage => null;

  @override
  PasswordValidationErrorMessage get passwordValidationErrorMessage => null;
}
