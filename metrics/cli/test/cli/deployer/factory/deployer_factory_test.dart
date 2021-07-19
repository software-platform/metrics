// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/cli/deployer/deployer.dart';
import 'package:cli/cli/deployer/factory/deployer_factory.dart';
import 'package:cli/common/model/services/services.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../test_utils/matchers.dart';
import '../../../test_utils/mocks/firebase_service_mock.dart';
import '../../../test_utils/mocks/flutter_service_mock.dart';
import '../../../test_utils/mocks/gcloud_service_mock.dart';
import '../../../test_utils/mocks/git_service_mock.dart';
import '../../../test_utils/mocks/npm_service_mock.dart';
import '../../../test_utils/mocks/sentry_service_mock.dart';
import '../../../test_utils/mocks/services_factory_mock.dart';

void main() {
  group("DeployerFactory", () {
    final servicesFactory = ServicesFactoryMock();
    final deployerFactory = DeployerFactory(servicesFactory);
    final gcloudService = GCloudServiceMock();
    final flutterService = FlutterServiceMock();
    final gitService = GitServiceMock();
    final npmService = NpmServiceMock();
    final firebaseService = FirebaseServiceMock();
    final sentryService = SentryServiceMock();
    final services = Services(
      flutterService: flutterService,
      gcloudService: gcloudService,
      gitService: gitService,
      npmService: npmService,
      firebaseService: firebaseService,
      sentryService: sentryService,
    );

    tearDown(() {
      reset(servicesFactory);
      reset(gcloudService);
      reset(flutterService);
      reset(gitService);
      reset(npmService);
      reset(firebaseService);
      reset(sentryService);
    });

    PostExpectation<Services> whenCreateServices() {
      return when(servicesFactory.create());
    }

    test(
      "throws an ArgumentError if the given services factory is null",
      () {
        expect(
          () => DeployerFactory(null),
          throwsArgumentError,
        );
      },
    );

    test(
      ".create() creates a Services instance using the given services factory",
      () {
        whenCreateServices().thenReturn(services);

        deployerFactory.create();

        verify(servicesFactory.create()).called(once);
      },
    );

    test(
      ".create() successfully creates a Deployer instance",
      () {
        whenCreateServices().thenReturn(services);

        final deployer = deployerFactory.create();

        expect(deployer, isA<Deployer>());
      },
    );
  });
}
