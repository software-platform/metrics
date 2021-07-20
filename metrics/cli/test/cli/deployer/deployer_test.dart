// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli/cli/deployer/deployer.dart';
import 'package:cli/cli/deployer/strings/deploy_strings.dart';
import 'package:cli/common/constants/deploy_constants.dart';
import 'package:cli/common/model/config/sentry_web_config.dart';
import 'package:cli/common/model/config/web_metrics_config.dart';
import 'package:cli/common/model/paths/factory/paths_factory.dart';
import 'package:cli/common/model/paths/paths.dart';
import 'package:cli/common/model/services/services.dart';
import 'package:cli/common/strings/common_strings.dart';
import 'package:cli/services/sentry/model/sentry_project.dart';
import 'package:cli/services/sentry/model/sentry_release.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../test_utils/extension/error_answer.dart';
import '../../test_utils/matchers.dart';
import '../../test_utils/mocks/directory_mock.dart';
import '../../test_utils/mocks/file_helper_mock.dart';
import '../../test_utils/mocks/file_mock.dart';
import '../../test_utils/mocks/firebase_service_mock.dart';
import '../../test_utils/mocks/flutter_service_mock.dart';
import '../../test_utils/mocks/gcloud_service_mock.dart';
import '../../test_utils/mocks/git_service_mock.dart';
import '../../test_utils/mocks/npm_service_mock.dart';
import '../../test_utils/mocks/path_factory_mock.dart';
import '../../test_utils/mocks/prompter_mock.dart';
import '../../test_utils/mocks/sentry_service_mock.dart';
import '../../test_utils/mocks/services_mock.dart';

// ignore_for_file: avoid_redundant_argument_values, avoid_implementing_value_types, must_be_immutable

void main() {
  group("Deployer", () {
    const projectId = 'testId';
    const clientId = 'clientId';
    const sentryReleaseName = 'sentryReleaseName';
    const sentryDsn = 'sentryDsn';
    const sentryProjectSlug = 'sentryProjectSlug';
    const sentryOrgSlug = 'sentryOrgSlug';
    const tempDirectoryPath = 'tempDirectoryPath';
    const stateErrorMessage = 'stateErrorMessage';
    const firebaseTarget = DeployConstants.firebaseTarget;
    const repoUrl = DeployConstants.repoUrl;

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
    final pathsFactoryMock = PathsFactoryMock();
    final pathsFactory = PathsFactory();
    final paths = Paths(tempDirectoryPath);
    final sentryProject = SentryProject(
      projectSlug: sentryProjectSlug,
      organizationSlug: sentryOrgSlug,
    );
    final sentryRelease = SentryRelease(
      name: sentryReleaseName,
      project: sentryProject,
    );

    final file = FileMock();
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
      pathsFactory: pathsFactory,
      prompter: prompter,
    );

    final stateError = StateError(stateErrorMessage);
    final failedDeploymentMessage = DeployStrings.failedDeployment(
      stateError,
    );
    final deleteProjectMessage = DeployStrings.deleteProject(projectId);

    PostExpectation<Directory> whenCreateTempDirectory() {
      return when(fileHelper.createTempDirectory(any, any));
    }

    PostExpectation<bool> whenDirectoryExists({
      Directory withDirectory,
      String withPath,
    }) {
      final tempDirectory = withDirectory ?? directory;
      whenCreateTempDirectory().thenReturn(tempDirectory);

      final currentPath = withPath ?? tempDirectoryPath;
      when(tempDirectory.path).thenReturn(currentPath);

      return when(tempDirectory.existsSync());
    }

    PostExpectation<Future<String>> whenCreateGCloudProject() {
      return when(gcloudService.createProject());
    }

    PostExpectation<bool> whenPromptToSetupSentry() {
      return when(prompter.promptConfirm(DeployStrings.setupSentry));
    }

    PostExpectation<SentryRelease> whenGetSentryRelease() {
      whenPromptToSetupSentry().thenReturn(true);

      return when(sentryService.getSentryRelease());
    }

    PostExpectation<Future<void>> whenCreateRelease() {
      whenPromptToSetupSentry().thenReturn(true);

      return when(sentryService.createRelease(any, any));
    }

    PostExpectation<bool> whenDeleteProject() {
      whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));

      return when(prompter.promptConfirm(deleteProjectMessage));
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
      reset(file);
      reset(pathsFactoryMock);
    });

    test(
      "throws an ArgumentError if the given services is null",
      () {
        expect(
          () => Deployer(
            services: null,
            fileHelper: fileHelper,
            prompter: prompter,
            pathsFactory: pathsFactory,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the given FileHelper is null",
      () {
        expect(
          () => Deployer(
            services: services,
            fileHelper: null,
            prompter: prompter,
            pathsFactory: pathsFactory,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the given Prompter is null",
      () {
        expect(
          () => Deployer(
            services: services,
            fileHelper: fileHelper,
            prompter: null,
            pathsFactory: pathsFactory,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the given PathsFactory is null",
      () {
        expect(
          () => Deployer(
            services: services,
            fileHelper: fileHelper,
            prompter: prompter,
            pathsFactory: null,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      ".deploy() logs in to the GCloud",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verify(gcloudService.login()).called(once);
      },
    );

    test(
      ".deploy() logs in to the GCloud before accepting the terms of the GCloud service",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          gcloudService.login(),
          gcloudService.acceptTermsOfService(),
        ]);
      },
    );

    test(
      ".deploy() accepts the terms of the GCloud service",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verify(gcloudService.acceptTermsOfService()).called(once);
      },
    );

    test(
      ".deploy() accepts the terms of the GCloud service before creating the GCloud project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          gcloudService.acceptTermsOfService(),
          gcloudService.createProject(),
        ]);
      },
    );

    test(
      ".deploy() logs in to the Firebase",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verify(firebaseService.login()).called(once);
      },
    );

    test(
      ".deploy() logs in to the Firebase before accepting the terms of the Firebase service",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          firebaseService.login(),
          firebaseService.acceptTermsOfService(),
        ]);
      },
    );

    test(
      ".deploy() accepts the terms of the Firebase service",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verify(firebaseService.acceptTermsOfService()).called(once);
      },
    );

    test(
      ".deploy() accepts the terms of the Firebase service before creating the Firebase web app",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          firebaseService.acceptTermsOfService(),
          firebaseService.createWebApp(any),
        ]);
      },
    );

    test(
      ".deploy() creates the GCloud project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verify(gcloudService.createProject()).called(once);
      },
    );

    test(
      ".deploy() creates the GCloud project before adding the Firebase for it",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));

        await deployer.deploy();

        verifyInOrder([
          gcloudService.createProject(),
          gcloudService.addFirebase(any),
        ]);
      },
    );

    test(
      ".deploy() creates the GCloud project before creating the Firebase web app",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          gcloudService.createProject(),
          firebaseService.createWebApp(any),
        ]);
      },
    );

    test(
      ".deploy() adds Firebase to the GCloud project with the created project id",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));

        await deployer.deploy();

        verify(gcloudService.addFirebase(projectId)).called(once);
      },
    );

    test(
      ".deploy() adds Firebase to the GCloud project before creating the Firebase web app",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));

        await deployer.deploy();

        verifyInOrder([
          gcloudService.addFirebase(projectId),
          firebaseService.createWebApp(projectId),
        ]);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if GCloud service throws during the Firebase adding",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(gcloudService.addFirebase(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if GCloud service throws during the Firebase adding",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(gcloudService.addFirebase(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(
          prompter.promptConfirm(deleteProjectMessage),
        ).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if GCloud service throws during the Firebase adding and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(gcloudService.addFirebase(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if GCloud service throws during the Firebase adding and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(gcloudService.addFirebase(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(any));
      },
    );

    test(
      ".deploy() deletes the temporary directory if GCloud service throws during the Firebase adding",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(gcloudService.addFirebase(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() configures organization for the GCloud project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));

        await deployer.deploy();

        verify(
          gcloudService.configureProjectOrganization(projectId),
        ).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if GCloud service throws during the organization configuration",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(
          gcloudService.configureProjectOrganization(any),
        ).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if GCloud service throws during the organization configuration",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(
          gcloudService.configureProjectOrganization(any),
        ).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if GCloud service throws during the organization configuration and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(
          gcloudService.configureProjectOrganization(any),
        ).thenThrow(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if GCloud service throws during the organization configuration and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(
          gcloudService.configureProjectOrganization(any),
        ).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(any));
      },
    );

    test(
      ".deploy() deletes the temporary directory if GCloud service throws during the organization configuration",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(
          gcloudService.configureProjectOrganization(any),
        ).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() creates the Firebase web app for the created GCloud project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));

        await deployer.deploy();

        verify(firebaseService.createWebApp(projectId)).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if Firebase service throws during the Firebase web app creation",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.createWebApp(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if Firebase service throws during the Firebase web app creation",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.createWebApp(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if Firebase service throws during the Firebase web app creation and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.createWebApp(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if Firebase service throws during the Firebase web app creation and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.createWebApp(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(any));
      },
    );

    test(
      ".deploy() deletes the temporary directory if Firebase service throws during the Firebase web app creation",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.createWebApp(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() creates a temporary directory",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verify(fileHelper.createTempDirectory(
          any,
          DeployConstants.tempDirectoryPrefix,
        )).called(once);
      },
    );

    test(
      ".deploy() creates a temporary directory before creating the Paths instance",
      () async {
        final deployer = Deployer(
          fileHelper: fileHelper,
          pathsFactory: pathsFactoryMock,
          prompter: prompter,
          services: services,
        );

        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(pathsFactoryMock.create(tempDirectoryPath)).thenReturn(paths);

        await deployer.deploy();

        verifyInOrder([
          fileHelper.createTempDirectory(any, any),
          pathsFactoryMock.create(tempDirectoryPath),
        ]);
      },
    );

    test(
      ".deploy() creates a Paths instance using the given factory",
      () async {
        final deployer = Deployer(
          fileHelper: fileHelper,
          pathsFactory: pathsFactoryMock,
          prompter: prompter,
          services: services,
        );

        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(pathsFactoryMock.create(tempDirectoryPath)).thenReturn(paths);

        await deployer.deploy();

        verify(pathsFactoryMock.create(tempDirectoryPath)).called(once);
      },
    );

    test(
      ".deploy() clones the Git repository to the temporary directory",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verify(gitService.checkout(repoUrl, tempDirectoryPath)).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if Git service throws during the checkout process",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(gitService.checkout(any, any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if Git service throws during the checkout process",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(gitService.checkout(any, any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if Git service throws during the checkout process and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(gitService.checkout(any, any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if Git service throws during the checkout process and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(gitService.checkout(any, any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(any));
      },
    );

    test(
      ".deploy() deletes the temporary directory if Git service throws during the checkout process",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(gitService.checkout(any, any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() clones the Git repository before building the Flutter application",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          gitService.checkout(repoUrl, tempDirectoryPath),
          flutterService.build(any),
        ]);
      },
    );

    test(
      ".deploy() clones the Git repository before installing the npm dependencies in the Firebase folder",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          gitService.checkout(repoUrl, tempDirectoryPath),
          npmService.installDependencies(any),
        ]);
      },
    );

    test(
      ".deploy() clones the Git repository before installing the npm dependencies in the Firebase functions folder",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          gitService.checkout(repoUrl, tempDirectoryPath),
          npmService.installDependencies(any),
        ]);
      },
    );

    test(
      ".deploy() installs the npm dependencies in the Firebase folder",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verify(npmService.installDependencies(paths.firebasePath)).called(once);
      },
    );

    test(
      ".deploy() installs the npm dependencies in the functions folder",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verify(
          npmService.installDependencies(paths.firebaseFunctionsPath),
        ).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if Npm service throws during the dependencies installing",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(npmService.installDependencies(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if Npm service throws during the dependencies installing",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(npmService.installDependencies(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if Npm service throws during the dependencies installing and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(npmService.installDependencies(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if Npm service throws during the dependencies installing and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(npmService.installDependencies(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(projectId));
      },
    );

    test(
      ".deploy() deletes the temporary directory if Npm service throws during the dependencies installing",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(
          npmService.installDependencies(any),
        ).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() installs the npm dependencies in the Firebase folder before deploying Firebase components",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          npmService.installDependencies(any),
          firebaseService.deployFirebase(any, any),
        ]);
      },
    );

    test(
      ".deploy() installs the npm dependencies in the functions folder before deploying Firebase components",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          npmService.installDependencies(any),
          firebaseService.deployFirebase(any, any),
        ]);
      },
    );

    test(
      ".deploy() builds the Flutter application",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verify(flutterService.build(paths.webAppPath)).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if Flutter service throws during the web application building",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(flutterService.build(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if Flutter service throws during the web application building",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(flutterService.build(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if Flutter service throws during the web application building and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(flutterService.build(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if Flutter service throws during the web application building and the user does not agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(flutterService.build(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(projectId));
      },
    );

    test(
      ".deploy() deletes the temporary directory if Flutter service throws during the web application building",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(flutterService.build(any)).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() builds the Flutter application before deploying to the hosting",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          flutterService.build(any),
          firebaseService.deployHosting(any, any, any),
        ]);
      },
    );

    test(
      ".deploy() upgrades the Firebase billing plan",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));

        await deployer.deploy();

        verify(firebaseService.upgradeBillingPlan(projectId)).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if Firebase service throws during the Firebase billing plan upgrading",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.upgradeBillingPlan(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if Firebase service throws during upgrading the Firebase billing plan",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.upgradeBillingPlan(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if Firebase service throws during upgrading the Firebase billing plan and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.upgradeBillingPlan(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if Firebase service throws during upgrading the Firebase billing plan and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.upgradeBillingPlan(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(projectId));
      },
    );

    test(
      ".deploy() deletes the temporary directory if Firebase service throws during upgrading the Firebase billing plan",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.upgradeBillingPlan(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() upgrades the Firebase billing plan before deploying the Firebase components",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          firebaseService.upgradeBillingPlan(any),
          firebaseService.deployFirebase(any, any),
        ]);
      },
    );

    test(
      ".deploy() enables the Firebase Analytics",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));

        await deployer.deploy();

        verify(firebaseService.enableAnalytics(projectId)).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if the Firebase service throws during enabling the Firebase Analytics",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.enableAnalytics(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if the Firebase service throws during enabling the Firebase Analytics",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.enableAnalytics(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if the Firebase service throws during enabling the Firebase Analytics and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.enableAnalytics(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if the Firebase service throws during enabling the Firebase Analytics and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.enableAnalytics(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(any));
      },
    );

    test(
      ".deploy() deletes the temporary directory if the Firebase service throws during enabling the Firebase Analytics",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.enableAnalytics(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() enables the Firebase Analytics before deploying to the hosting",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          firebaseService.enableAnalytics(any),
          firebaseService.deployHosting(any, any, any),
        ]);
      },
    );

    test(
      ".deploy() initializes the Firestore data",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));

        await deployer.deploy();

        verify(firebaseService.initializeFirestoreData(projectId)).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if the Firebase service throws during initializing the Firestore data",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(
          firebaseService.initializeFirestoreData(any),
        ).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if the Firebase service throws during initializing the Firestore data",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(
          firebaseService.initializeFirestoreData(any),
        ).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if the Firebase service throws during initializing the Firestore data and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(
          firebaseService.initializeFirestoreData(any),
        ).thenThrow(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if the Firebase service throws during initializing the Firestore data and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(
          firebaseService.initializeFirestoreData(any),
        ).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(projectId));
      },
    );

    test(
      ".deploy() deletes the temporary directory if the Firebase service throws during initializing the Firestore data",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(
          firebaseService.initializeFirestoreData(any),
        ).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() initializes the Firestore data before deploying to the hosting",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          firebaseService.initializeFirestoreData(any),
          firebaseService.deployHosting(any, any, any),
        ]);
      },
    );

    test(
      ".deploy() configures the Firebase auth providers",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));

        await deployer.deploy();

        verify(firebaseService.configureAuthProviders(projectId)).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if the Firebase service throws during the Firebase auth providers configuration",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.configureAuthProviders(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if the Firebase service throws during the Firebase auth providers configuration",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.configureAuthProviders(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if the Firebase service throws during the Firebase auth providers configuration and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.configureAuthProviders(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if the Firebase service throws during the Firebase auth providers configuration and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.configureAuthProviders(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(any));
      },
    );

    test(
      ".deploy() deletes the temporary directory if the Firebase service throws during the Firebase auth providers configuration",
      () async {
        whenDirectoryExists().thenReturn(true);
        when(firebaseService.configureAuthProviders(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() configures the Firebase auth providers before deploying to the hosting",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          firebaseService.configureAuthProviders(any),
          firebaseService.deployHosting(any, any, any),
        ]);
      },
    );

    test(
      ".deploy() prompts the user whether to configure Sentry",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(DeployStrings.setupSentry)).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if prompter throws during prompting the Sentry config",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if prompter throws during prompting the Sentry config",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if prompter throws during prompting the Sentry config and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenThrow(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if prompter throws during prompting the Sentry config and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(any));
      },
    );

    test(
      ".deploy() deletes the temporary directory if prompter throws during prompting the Sentry config",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() prompts the user to configure the Sentry before logging in to the Sentry",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(true);
        whenGetSentryRelease().thenReturn(sentryRelease);

        await deployer.deploy();

        verifyInOrder([
          prompter.promptConfirm(DeployStrings.setupSentry),
          sentryService.login(),
        ]);
      },
    );

    test(
      ".deploy() logs in to the Sentry if the user agrees with the Sentry setup",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(true);
        whenGetSentryRelease().thenReturn(sentryRelease);

        await deployer.deploy();

        verify(sentryService.login()).called(once);
      },
    );

    test(
      ".deploy() does not log in to the Sentry if the user does not agree with the Sentry setup",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyNever(sentryService.login());
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if Sentry service throws during the login process",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(true);
        when(sentryService.login()).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if Sentry service throws during the login process",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(true);
        when(sentryService.login()).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if Sentry service throws during the login process and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(true);
        when(sentryService.login()).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if Sentry service throws during the login process and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(true);
        when(sentryService.login()).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(projectId));
      },
    );

    test(
      ".deploy() deletes the temporary directory if Sentry service throws during the login process",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(true);
        when(sentryService.login()).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() logs in to the Sentry before creating the Sentry release",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(true);
        whenGetSentryRelease().thenReturn(sentryRelease);

        await deployer.deploy();

        verifyInOrder([
          sentryService.login(),
          sentryService.createRelease(any, any),
        ]);
      },
    );

    test(
      ".deploy() gets the Sentry release using the SentryService",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(true);
        whenGetSentryRelease().thenReturn(sentryRelease);

        await deployer.deploy();

        verify(sentryService.getSentryRelease()).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if Sentry service throws during getting a release",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenGetSentryRelease().thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if Sentry service throws during getting a release",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenGetSentryRelease().thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if Sentry service throws during getting a release, and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenGetSentryRelease().thenThrow(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if Sentry service throws during getting a release, and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenGetSentryRelease().thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(projectId));
      },
    );

    test(
      ".deploy() deletes the temporary directory if Sentry service throws during getting a release",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenGetSentryRelease().thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() gets the Sentry release before creating a new one",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenGetSentryRelease().thenReturn(sentryRelease);

        await deployer.deploy();

        verifyInOrder([
          sentryService.getSentryRelease(),
          sentryService.createRelease(any, any),
        ]);
      },
    );

    test(
      ".deploy() creates the Sentry release",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(true);
        whenGetSentryRelease().thenReturn(sentryRelease);

        await deployer.deploy();

        verify(sentryService.createRelease(any, any)).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if Sentry service throws during the release creation",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenGetSentryRelease().thenReturn(sentryRelease);
        whenCreateRelease().thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if Sentry service throws during the release creation",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenCreateRelease().thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if Sentry service throws during the release creation and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenCreateRelease().thenAnswerError(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if Sentry service throws during the release creation and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenCreateRelease().thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(projectId));
      },
    );

    test(
      ".deploy() deletes the temporary directory if Sentry service throws during the release creation",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenCreateRelease().thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() requests the Sentry DSN of the created project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenGetSentryRelease().thenReturn(sentryRelease);

        await deployer.deploy();

        verify(sentryService.getProjectDsn(sentryRelease.project)).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if prompter throws during requesting the Sentry DSN",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenGetSentryRelease().thenReturn(sentryRelease);
        when(sentryService.getProjectDsn(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if prompter throws during requesting the Sentry DSN",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenGetSentryRelease().thenReturn(sentryRelease);
        when(sentryService.getProjectDsn(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if prompter throws during requesting the Sentry DSN and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenGetSentryRelease().thenReturn(sentryRelease);
        when(sentryService.getProjectDsn(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if prompter throws during requesting the Sentry DSN and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenGetSentryRelease().thenReturn(sentryRelease);
        when(sentryService.getProjectDsn(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(any));
      },
    );

    test(
      ".deploy() deletes the temporary directory if prompter throws during requesting the Sentry DSN",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenGetSentryRelease().thenReturn(sentryRelease);
        when(sentryService.getProjectDsn(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() gets the Metrics config file using the given FileHelper",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));

        await deployer.deploy();

        verify(fileHelper.getFile(paths.metricsConfigPath)).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if FileHelper throws during the Metrics config file getting",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(fileHelper.getFile(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if FileHelper throws during the Metrics config file getting",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(fileHelper.getFile(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if FileHelper throws during the Metrics config file getting and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(fileHelper.getFile(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if FileHelper throws during the Metrics config file getting and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(fileHelper.getFile(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(projectId));
      },
    );

    test(
      ".deploy() deletes the temporary directory if FileHelper throws during the Metrics config file getting",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(fileHelper.getFile(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() replaces the environment variables in the Metrics config file returned by FileHelper with the user-specified values",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(true);
        when(firebaseService.configureAuthProviders(any)).thenReturn(clientId);
        whenGetSentryRelease().thenReturn(sentryRelease);
        when(sentryService.getProjectDsn(any)).thenReturn(sentryDsn);
        when(fileHelper.getFile(any)).thenReturn(file);

        final sentryWebConfig = SentryWebConfig(
          release: sentryRelease.name,
          dsn: sentryDsn,
          environment: DeployConstants.sentryEnvironment,
        );
        final config = WebMetricsConfig(
          googleSignInClientId: clientId,
          sentryWebConfig: sentryWebConfig,
        );

        await deployer.deploy();

        verify(
          fileHelper.replaceEnvironmentVariables(file, config.toMap()),
        ).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if FileHelper throws during replacing variables in the Metrics config file",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(
          fileHelper.replaceEnvironmentVariables(any, any),
        ).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if FileHelper throws during replacing variables in the Metrics config file",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(
          fileHelper.replaceEnvironmentVariables(any, any),
        ).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if FileHelper throws during replacing variables in the Metrics config file and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(
          fileHelper.replaceEnvironmentVariables(any, any),
        ).thenThrow(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if FileHelper throws during replacing variables in the Metrics config file and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(
          fileHelper.replaceEnvironmentVariables(any, any),
        ).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(projectId));
      },
    );

    test(
      ".deploy() deletes the temporary directory if FileHelper throws during replacing variables in the Metrics config file",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(
          fileHelper.replaceEnvironmentVariables(any, any),
        ).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() updates the Metrics config file before deploying to the hosting",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          fileHelper.replaceEnvironmentVariables(any, any),
          firebaseService.deployHosting(any, any, any),
        ]);
      },
    );

    test(
      ".deploy() deploys Firebase components to the Firebase",
      () async {
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verify(firebaseService.deployFirebase(
          projectId,
          paths.firebasePath,
        )).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if Firebase service throws during the Firebase components deployment",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(
          firebaseService.deployFirebase(any, any),
        ).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if Firebase service throws during the Firebase components deployment",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(
          firebaseService.deployFirebase(any, any),
        ).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if Firebase service throws during the Firebase components deployment and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(
          firebaseService.deployFirebase(any, any),
        ).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if Firebase service throws during the Firebase components deployment and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(
          firebaseService.deployFirebase(any, any),
        ).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(projectId));
      },
    );

    test(
      ".deploy() deletes the temporary directory if Firebase service throws during the Firebase components deployment",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(
          firebaseService.deployFirebase(any, any),
        ).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() deploys Firebase components before deploying to the hosting",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

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
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));

        await deployer.deploy();

        verify(firebaseService.deployHosting(
          projectId,
          firebaseTarget,
          paths.webAppPath,
        )).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if Firebase service throws during the Firebase hosting deployment",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(
          firebaseService.deployHosting(any, any, any),
        ).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if Firebase service throws during the Firebase hosting deployment",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(
          firebaseService.deployHosting(any, any, any),
        ).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if Firebase service throws during the Firebase hosting deployment and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(
          firebaseService.deployHosting(any, any, any),
        ).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if Firebase service throws during the Firebase hosting deployment and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(
          firebaseService.deployHosting(any, any, any),
        ).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(projectId));
      },
    );

    test(
      ".deploy() deletes the temporary directory if Firebase service throws during the Firebase hosting deployment",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(
          firebaseService.deployHosting(any, any, any),
        ).thenAnswerError(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() deploys a target to the hosting before configuring GCloud OAuth origins",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyInOrder([
          firebaseService.deployHosting(any, any, any),
          gcloudService.configureOAuthOrigins(any),
        ]);
      },
    );

    test(
      ".deploy() configures GCloud OAuth Authorized JavaScript origins",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));

        await deployer.deploy();

        verify(gcloudService.configureOAuthOrigins(projectId)).called(once);
      },
    );

    test(
      ".deploy() informs the user about the failed deployment if GCloud service throws during the OAuth origins configuration",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(gcloudService.configureOAuthOrigins(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.error(failedDeploymentMessage)).called(once);
      },
    );

    test(
      ".deploy() suggests deleting the GCloud project if GCloud service throws during the OAuth origins configuration",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(gcloudService.configureOAuthOrigins(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(prompter.promptConfirm(deleteProjectMessage)).called(once);
      },
    );

    test(
      ".deploy() deletes the GCloud project if GCloud service throws during the OAuth origins configuration and the user agrees to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(gcloudService.configureOAuthOrigins(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(true);

        await deployer.deploy();

        verify(gcloudService.deleteProject(projectId)).called(once);
      },
    );

    test(
      ".deploy() does not delete the GCloud project if GCloud service throws during the OAuth origins configuration and the user does not agree to delete the project",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(gcloudService.configureOAuthOrigins(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verifyNever(gcloudService.deleteProject(any));
      },
    );

    test(
      ".deploy() deletes the temporary directory if GCloud service throws during the OAuth origins configuration",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        when(gcloudService.configureOAuthOrigins(any)).thenThrow(stateError);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() configures GCloud OAuth origins before deleting the temporary directory",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        whenCreateGCloudProject().thenAnswer((_) => Future.value(projectId));

        await deployer.deploy();

        verifyInOrder([
          gcloudService.configureOAuthOrigins(any),
          directory.deleteSync(recursive: true),
        ]);
      },
    );

    test(
      ".deploy() deletes the temporary directory if it exists",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);
        whenDeleteProject().thenReturn(false);

        await deployer.deploy();

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".deploy() informs about deleting the temporary directory",
      () async {
        whenDirectoryExists().thenReturn(true);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verify(prompter.info(CommonStrings.deletingTempDirectory)).called(once);
      },
    );

    test(
      ".deploy() does not delete the temporary directory if it does not exist",
      () async {
        whenDirectoryExists().thenReturn(false);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verifyNever(directory.delete(recursive: true));
      },
    );

    test(
      ".deploy() informs about the successful deployment if deployment succeeds",
      () async {
        whenDirectoryExists().thenReturn(false);
        whenPromptToSetupSentry().thenReturn(false);

        await deployer.deploy();

        verify(prompter.info(DeployStrings.successfulDeployment)).called(once);
      },
    );
  });
}
