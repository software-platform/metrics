import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/debug_menu/domain/usecases/parameters/local_config_param.dart';
import 'package:metrics/debug_menu/domain/usecases/update_local_config_usecase.dart';
import 'package:mockito/mockito.dart';

import '../../../test_utils/local_config_repository_mock.dart';

// ignore_for_file: avoid_redundant_argument_values

void main() {
  group("UpdateLocalConfigUseCase", () {
    final repository = LocalConfigRepositoryMock();
    final useCase = UpdateLocalConfigUseCase(repository);

    tearDown(() {
      reset(repository);
    });

    test(
      "throws an ArgumentError if the given repository is null",
      () {
        expect(
          () => UpdateLocalConfigUseCase(null),
          throwsArgumentError,
        );
      },
    );

    test(
      "creates an instance with the given repository",
      () {
        expect(
          () => UpdateLocalConfigUseCase(repository),
          returnsNormally,
        );
      },
    );

    test(
      ".call() uses the .updateConfig() method of the local config repository",
      () {
        const isFpsMonitorEnabled = false;
        final param = LocalConfigParam(
          isFpsMonitorEnabled: isFpsMonitorEnabled,
        );

        useCase(param);

        verify(
          repository.updateConfig(isFpsMonitorEnabled: isFpsMonitorEnabled),
        ).called(1);
      },
    );
  });
}
