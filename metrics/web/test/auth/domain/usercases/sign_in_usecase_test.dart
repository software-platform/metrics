import 'package:metrics/auth/domain/entities/authentication_exception.dart';
import 'package:metrics/auth/domain/usecases/parameters/user_credentials_param.dart';
import 'package:metrics/auth/domain/usecases/sign_in_usecase.dart';
import 'package:metrics_core/metrics_core.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../test_utils/matcher_util.dart';
import '../../../test_utils/user_repository_mock.dart';

void main() {
  group("SignInUseCase", () {
    final repository = UserRepositoryMock();

    tearDown(() {
      reset(repository);
    });

    final userCredentials = UserCredentialsParam(
      email: EmailValueObject('email@mail.mail'),
      password: PasswordValueObject('password'),
    );

    test("can't be created with null repository", () {
      expect(
        () => SignInUseCase(null),
        MatcherUtil.throwsAssertionError,
      );
    });

    test(
      "delegates call to the UserRepository.signInWithEmailAndPassword",
      () async {
        final signInUseCase = SignInUseCase(repository);

        await signInUseCase(userCredentials);

        verify(repository.signInWithEmailAndPassword(
          userCredentials.email.value,
          userCredentials.password.value,
        )).called(equals(1));
      },
    );

    test(
      "throws if UserRepository throws during sign in process",
      () {
        final signInUseCase = SignInUseCase(repository);

        when(repository.signInWithEmailAndPassword(any, any))
            .thenThrow(const AuthenticationException());

        expect(
          () => signInUseCase(userCredentials),
          MatcherUtil.throwsAuthenticationException,
        );
      },
    );
  });
}
