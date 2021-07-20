// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/cli/updater/factory/updater_factory.dart';
import 'package:cli/cli/updater/updater.dart';
import 'package:cli/common/model/services/services.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../test_utils/matchers.dart';
import '../../../test_utils/mocks/services_factory_mock.dart';

void main() {
  group("UpdaterFactory", () {
    final servicesFactory = ServicesFactoryMock();
    final services = _ServicesMock();
    final updaterFactory = UpdaterFactory(servicesFactory);

    tearDown(() {
      reset(servicesFactory);
      reset(services);
    });

    test(
      "throws an ArgumentError if the given services factory is null",
      () {
        expect(
          () => UpdaterFactory(null),
          throwsArgumentError,
        );
      },
    );

    test(
      ".create() creates a Services instance using the given services factory",
      () {
        when(servicesFactory.create()).thenReturn(services);

        updaterFactory.create();

        verify(servicesFactory.create()).called(once);
      },
    );

    test(
      ".create() successfully creates an Updater instance",
      () {
        when(servicesFactory.create()).thenReturn(services);

        final updater = updaterFactory.create();

        expect(updater, isA<Updater>());
      },
    );
  });
}

class _ServicesMock extends Mock implements Services {}
