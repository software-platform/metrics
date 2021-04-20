// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli/common/model/services.dart';
import 'package:cli/deploy/constants/deploy_constants.dart';
import 'package:cli/deploy/deployer.dart';
import 'package:cli/deploy/strings/deploy_strings.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../test_utils/directory_mock.dart';
import '../test_utils/file_helper_mock.dart';
import '../test_utils/firebase_service_mock.dart';
import '../test_utils/flutter_service_mock.dart';
import '../test_utils/gcloud_service_mock.dart';
import '../test_utils/git_service_mock.dart';
import '../test_utils/matchers.dart';
import '../test_utils/npm_service_mock.dart';
import '../test_utils/prompter_mock.dart';
import '../test_utils/sentry_service_mock.dart';
import '../test_utils/services_mock.dart';

// ignore_for_file: avoid_redundant_argument_values

void main() {
  group("Deployer", () {
    const projectId = 'testId';
    const firebasePath = DeployConstants.firebasePath;
    const firebaseFunctionsPath = DeployConstants.firebaseFunctionsPath;
    const firebaseTarget = DeployConstants.firebaseTarget;
    const webPath = DeployConstants.webPath;
    const repoURL = DeployConstants.repoURL;
    const tempDir = DeployConstants.tempDir;

    final flutterService = FlutterServiceMock();
    final gcloudService = GCloudServiceMock();
    final npmService = NpmServiceMock();
    final gitService = GitServiceMock();
    final firebaseService = FirebaseServiceMock();
    final sentryService = SentryServiceMock();
    final fileHelper = FileHelperMock();
    final prompter = PrompterMock();
    final directory = DirectoryMock();
    final servicesMock = ServicesMock();
    final services = Services(
      flutterService: flutterService,
      gcloudService: gcloudService,
      npmService: npmService,
      gitService: gitService,
      firebaseService: firebaseService,
      sentryService: sentryService,
    );
    final deployer = Deployer(
      services: services,
      fileHelper: fileHelper,
      prompter: prompter,
    );
    final stateError = StateError('test');

    PostExpectation<Directory> whenGetDirectory() {
      return when(fileHelper.getDirectory(any));
    }

    PostExpectation<bool> whenDirectoryExist() {
      return when(directory.existsSync());
    }

    PostExpectation<Future<String>> whenCreateGCloudProject() {
      return when(gcloudService.createProject());
    }

    PostExpectation<bool> whenSetupSentry() {
      return when(prompter.promptConfirm(DeployStrings.setupSentry));
    }

    tearDown(() {
      reset(flutterService);
      reset(gcloudService);
      reset(npmService);
      reset(gitService);
      reset(firebaseService);
      reset(sentryService);
      reset(fileHelper);
      reset(directory);
      reset(servicesMock);
      reset(prompter);
    });

    test(
      "throws an ArgumentError if the given services is null",
      () {
        expect(
          () => Deployer(
            services: null,
            fileHelper: fileHelper,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the Flutter service in the given services is null",
      () {
        when(servicesMock.flutterService).thenReturn(null);
        when(servicesMock.gcloudService).thenReturn(gcloudService);
        when(servicesMock.npmService).thenReturn(npmService);
        when(servicesMock.gitService).thenReturn(gitService);
        when(servicesMock.firebaseService).thenReturn(firebaseService);
        when(servicesMock.sentryService).thenReturn(sentryService);

        expect(
          () => Deployer(services: servicesMock, fileHelper: fileHelper),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the GCloud service in the given services is null",
      () {
        when(servicesMock.flutterService).thenReturn(flutterService);
        when(servicesMock.gcloudService).thenReturn(null);
        when(servicesMock.npmService).thenReturn(npmService);
        when(servicesMock.gitService).thenReturn(gitService);
        when(servicesMock.firebaseService).thenReturn(firebaseService);
        when(servicesMock.sentryService).thenReturn(sentryService);

        expect(
          () => Deployer(services: servicesMock, fileHelper: fileHelper),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the Npm service in the given services is null",
      () {
        when(servicesMock.flutterService).thenReturn(flutterService);
        when(servicesMock.gcloudService).thenReturn(gcloudService);
        when(servicesMock.npmService).thenReturn(null);
        when(servicesMock.gitService).thenReturn(gitService);
        when(servicesMock.firebaseService).thenReturn(firebaseService);
        when(servicesMock.sentryService).thenReturn(sentryService);

        expect(
          () => Deployer(services: servicesMock, fileHelper: fileHelper),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the Git service in the given services is null",
      () {
        when(servicesMock.flutterService).thenReturn(flutterService);
        when(servicesMock.gcloudService).thenReturn(gcloudService);
        when(servicesMock.npmService).thenReturn(npmService);
        when(servicesMock.gitService).thenReturn(null);
        when(servicesMock.firebaseService).thenReturn(firebaseService);
        when(servicesMock.sentryService).thenReturn(sentryService);

        expect(
          () => Deployer(services: servicesMock, fileHelper: fileHelper),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the Firebase service in the given services is null",
      () {
        when(servicesMock.flutterService).thenReturn(flutterService);
        when(servicesMock.gcloudService).thenReturn(gcloudService);
        when(servicesMock.npmService).thenReturn(npmService);
        when(servicesMock.gitService).thenReturn(gitService);
        when(servicesMock.firebaseService).thenReturn(null);
        when(servicesMock.sentryService).thenReturn(sentryService);

        expect(
          () => Deployer(services: servicesMock, fileHelper: fileHelper),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the Sentry service in the given services is null",
      () {
        when(servicesMock.flutterService).thenReturn(flutterService);
        when(servicesMock.gcloudService).thenReturn(gcloudService);
        when(servicesMock.npmService).thenReturn(npmService);
        when(servicesMock.gitService).thenReturn(gitService);
        when(servicesMock.firebaseService).thenReturn(firebaseService);
        when(servicesMock.sentryService).thenReturn(null);

        expect(
          () => Deployer(services: servicesMock, fileHelper: fileHelper),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the given file helper is null",
      () {
        expect(
          () => Deployer(
            services: services,
            fileHelper: null,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      ".deploy() logs in to the GCloud",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.login()).called(once);
      },
    );

    test(
      ".deploy() logs in to the GCloud before creating the GCloud project",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verifyInOrder([
          gcloudService.login(),
          gcloudService.createProject(),
        ]);
      },
    );

    test(
      ".deploy() creates the GCloud project",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.createProject()).called(once);
      },
    );

    test(
      ".deploy() logs in to the Firebase",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.createProject()).called(once);
      },
    );

    test(
      ".deploy() logs in to the Firebase before creating the Firebase web app",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verifyInOrder([
          firebaseService.login(),
          firebaseService.createWebApp(any),
        ]);
      },
    );

    test(
      ".deploy() creates the Firebase web app for the created GCloud project",
      () async {
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verify(firebaseService.createWebApp(projectId)).called(once);
      },
    );

    test(
      ".deploy() clones the Git repository",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verify(gitService.checkout(repoURL, tempDir)).called(once);
      },
    );

    test(
      ".deploy() deletes the temporary directory if Git service throws during the checkout process",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);
        when(gitService.checkout(any, any))
            .thenAnswer((_) => Future.error(stateError));

        await expectLater(deployer.deploy(), throwsStateError);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() clones the Git repository before building the Flutter application",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verifyInOrder([
          gitService.checkout(repoURL, tempDir),
          flutterService.build(webPath),
        ]);
      },
    );

    test(
      ".deploy() clones the Git repository before installing the Npm dependencies to the Firebase folder",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verifyInOrder([
          gitService.checkout(repoURL, tempDir),
          npmService.installDependencies(DeployConstants.firebasePath),
        ]);
      },
    );

    test(
      ".deploy() clones the Git repository before installing the Npm dependencies to the Firebase functions folder",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verifyInOrder([
          gitService.checkout(repoURL, tempDir),
          npmService.installDependencies(DeployConstants.firebaseFunctionsPath),
        ]);
      },
    );

    test(
      ".deploy() installs the npm dependencies",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verify(npmService.installDependencies(firebasePath)).called(once);
        verify(npmService.installDependencies(firebaseFunctionsPath))
            .called(once);
      },
    );

    test(
      ".deploy() deletes the temporary directory if Npm service throws during the dependencies installing",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);
        when(npmService.installDependencies(any))
            .thenAnswer((_) => Future.error(stateError));

        await expectLater(deployer.deploy(), throwsStateError);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() installs the npm dependencies in the Firebase folder before deploying to the Firebase",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verifyInOrder([
          npmService.installDependencies(firebasePath),
          firebaseService.deployFirebase(any, any),
        ]);
      },
    );

    test(
      ".deploy() installs the npm dependencies to the functions folder before deploying to the Firebase",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verifyInOrder([
          npmService.installDependencies(firebaseFunctionsPath),
          firebaseService.deployFirebase(any, any),
        ]);
      },
    );

    test(
      ".deploy() builds the Flutter application",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verify(flutterService.build(webPath)).called(once);
      },
    );

    test(
      ".deploy() deletes the temporary directory if Flutter service throws during the web application building",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);
        when(flutterService.build(any))
            .thenAnswer((_) => Future.error(stateError));

        await expectLater(deployer.deploy(), throwsStateError);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() builds the Flutter application before deploying to the hosting",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verifyInOrder([
          flutterService.build(any),
          firebaseService.deployHosting(any, any, any),
        ]);
      },
    );

    test(
      ".deploy() builds the Flutter application before the Sentry configuration prompting",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verifyInOrder([
          flutterService.build(any),
          prompter.promptConfirm(DeployStrings.setupSentry),
        ]);
      },
    );

    test(
      ".deploy() prompts the user to configure the Sentry",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verify(prompter.promptConfirm(DeployStrings.setupSentry)).called(once);
      },
    );

    test(
      ".deploy() deletes the temporary directory if prompter throws during the Sentry config prompting",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenThrow(stateError);

        await expectLater(deployer.deploy(), throwsStateError);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() prompts the user to configure the Sentry before the Sentry release creation",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verifyInOrder([
          prompter.promptConfirm(DeployStrings.setupSentry),
          sentryService.createRelease(any, any, any)
        ]);
      },
    );

    test(
      ".deploy() logs in to the Sentry if the user's prompt returns true",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verify(sentryService.login()).called(once);
      },
    );

    test(
      ".deploy() does not log in to the Sentry if the user's prompt returns false",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyNever(sentryService.login());
      },
    );

    test(
      ".deploy() deletes the temporary directory if Sentry service throws during the login process",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);
        when(sentryService.login()).thenAnswer((_) => Future.error(stateError));

        await expectLater(deployer.deploy(), throwsStateError);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() logs in to the Sentry before creating the Sentry release",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verifyInOrder([
          gcloudService.login(),
          gcloudService.createProject(),
        ]);
      },
    );

    test(
      ".deploy() creates the Sentry release if the user's prompt returns true",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verify(sentryService.createRelease(
          DeployConstants.webPath,
          DeployConstants.buildWebPath,
          DeployConstants.configPath,
        )).called(once);
      },
    );

    test(
      ".deploy() does not create the Sentry release if the user's prompt returns false",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyNever(sentryService.createRelease(
          DeployConstants.webPath,
          DeployConstants.buildWebPath,
          DeployConstants.configPath,
        ));
      },
    );

    test(
      ".deploy() deletes the temporary directory if Sentry service throws during the release creation",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);
        when(sentryService.createRelease(any, any, any))
            .thenAnswer((_) => Future.error(stateError));

        await expectLater(deployer.deploy(), throwsStateError);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() deploys Firebase components to the Firebase",
      () async {
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verify(firebaseService.deployFirebase(projectId, firebasePath))
            .called(once);
      },
    );

    test(
      ".deploy() deletes the temporary directory if Firebase service throws during the Firebase components deployment",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);
        when(firebaseService.deployFirebase(any, any))
            .thenAnswer((_) => Future.error(stateError));

        await expectLater(deployer.deploy(), throwsStateError);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() deploys Firebase components before deploying to the hosting",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verifyInOrder([
          firebaseService.deployFirebase(any, any),
          firebaseService.deployHosting(any, any, any),
        ]);
      },
    );

    test(
      ".deploy() deploys the target to the hosting",
      () async {
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verify(firebaseService.deployHosting(
          projectId,
          firebaseTarget,
          webPath,
        )).called(once);
      },
    );

    test(
      ".deploy() deletes the temporary directory if Firebase service throws during the Firebase hosting deployment",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);
        when(firebaseService.deployHosting(any, any, any))
            .thenAnswer((_) => Future.error(stateError));

        await expectLater(deployer.deploy(), throwsStateError);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() deploys a target to the hosting before deleting the temporary directory",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verifyInOrder([
          firebaseService.deployHosting(any, any, any),
          directory.deleteSync(recursive: true),
        ]);
      },
    );

    test(
      ".deploy() deletes the temporary directory if it exists",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(true);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() does not delete the temporary directory if it does not exist",
      () async {
        whenGetDirectory().thenReturn(directory);
        whenDirectoryExist().thenReturn(false);
        whenSetupSentry().thenReturn(true);

        await deployer.deploy();

        verifyNever(directory.delete(recursive: true));
      },
    );
  });
}
