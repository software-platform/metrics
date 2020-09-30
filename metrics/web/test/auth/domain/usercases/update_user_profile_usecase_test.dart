import 'package:metrics/auth/domain/entities/theme_type.dart';
import 'package:metrics/auth/domain/usecases/parameters/user_profile_param.dart';
import 'package:metrics/auth/domain/usecases/update_user_profile_usecase.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../test_utils/user_repository_mock.dart';

void main() {
  group("UpdateUserProfileUseCase", () {
    final repository = UserRepositoryMock();
    const id = 'id';
    const selectedTheme = ThemeType.dark;
    final userProfileParam = UserProfileParam(
      id: id,
      selectedTheme: selectedTheme,
    );

    tearDown(() {
      reset(repository);
    });

    test("throws an ArgumentError if the given repository is null", () {
      expect(
        () => UpdateUserProfileUseCase(null),
        throwsArgumentError,
      );
    });

    test("delegates call to the given repository", () {
      final updateProfile = UpdateUserProfileUseCase(repository);

      updateProfile(userProfileParam);

      verify(repository.updateUserProfile(id, selectedTheme)).called(equals(1));
    });

    test("throws if the given repository throws during updating profile", () {
      const errorMessage = 'error message';

      when(repository.updateUserProfile(any, any)).thenThrow(errorMessage);

      final createProfile = UpdateUserProfileUseCase(repository);

      expect(
        () => createProfile(userProfileParam),
        throwsA(equals(errorMessage)),
      );
    });
  });
}
