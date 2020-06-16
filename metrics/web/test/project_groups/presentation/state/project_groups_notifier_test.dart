import 'dart:async';

import 'package:flutter/services.dart';
import 'package:metrics/common/presentation/constants/duration_constants.dart';
import 'package:metrics/common/presentation/models/project_model.dart';
import 'package:metrics/common/presentation/strings/common_strings.dart';
import 'package:metrics/project_groups/domain/entities/project_group.dart';
import 'package:metrics/project_groups/domain/usecases/add_project_group_usecase.dart';
import 'package:metrics/project_groups/domain/usecases/delete_project_group_usecase.dart';
import 'package:metrics/project_groups/domain/usecases/parameters/add_project_group_param.dart';
import 'package:metrics/project_groups/domain/usecases/parameters/delete_project_group_param.dart';
import 'package:metrics/project_groups/domain/usecases/parameters/update_project_group_param.dart';
import 'package:metrics/project_groups/domain/usecases/receive_project_group_updates.dart';
import 'package:metrics/project_groups/domain/usecases/update_project_group_usecase.dart';
import 'package:metrics/project_groups/presentation/state/project_groups_notifier.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/subjects.dart';
import 'package:test/test.dart';

import '../../../test_utils/matcher_util.dart';

void main() {
  group("ProjectGroupsNotifier", () {
    const projectGroupId = 'testId';
    const projectGroupName = 'testName';
    const projectIds = ['testProjectId'];

    final addProjectGroupUseCase = AddProjectGroupUseCaseMock();
    final updateProjectGroupUseCase = UpdateProjectGroupUseCaseMock();
    final deleteProjectGroupUseCase = DeleteProjectGroupUseCaseMock();
    final receiveProjectGroupUpdates = ReceiveProjectGroupUpdatesMock();

    final projectGroupsNotifier = ProjectGroupsNotifier(
      receiveProjectGroupUpdates,
      addProjectGroupUseCase,
      updateProjectGroupUseCase,
      deleteProjectGroupUseCase,
    );

    tearDown(() {
      reset(addProjectGroupUseCase);
      reset(updateProjectGroupUseCase);
      reset(deleteProjectGroupUseCase);
      reset(receiveProjectGroupUpdates);
    });

    tearDownAll(() {
      projectGroupsNotifier.dispose();
    });

    test(
      "throws an AssertionError if the receive project group updates use case is null",
      () {
        expect(
          () => ProjectGroupsNotifier(
            null,
            addProjectGroupUseCase,
            updateProjectGroupUseCase,
            deleteProjectGroupUseCase,
          ),
          MatcherUtil.throwsAssertionError,
        );
      },
    );

    test(
      "throws an AssertionError if the add project group use case is null",
      () {
        expect(
          () => ProjectGroupsNotifier(
            receiveProjectGroupUpdates,
            null,
            updateProjectGroupUseCase,
            deleteProjectGroupUseCase,
          ),
          MatcherUtil.throwsAssertionError,
        );
      },
    );
    test(
      "throws an AssertionError if the update project group use case is null",
      () {
        expect(
          () => ProjectGroupsNotifier(
            receiveProjectGroupUpdates,
            addProjectGroupUseCase,
            null,
            deleteProjectGroupUseCase,
          ),
          MatcherUtil.throwsAssertionError,
        );
      },
    );

    test(
      "throws an AssertionError if the delete project group use case is null",
      () {
        expect(
          () => ProjectGroupsNotifier(
            receiveProjectGroupUpdates,
            addProjectGroupUseCase,
            updateProjectGroupUseCase,
            null,
          ),
          MatcherUtil.throwsAssertionError,
        );
      },
    );

    test(
      ".subscribeToProjectGroups() completes normally if a receiveProjectGroupUpdates is null",
      () async {
        when(receiveProjectGroupUpdates()).thenAnswer(
          (_) => Stream.value(null),
        );

        await expectLater(
          projectGroupsNotifier.subscribeToProjectGroups(),
          completes,
        );

        final projectGroups = projectGroupsNotifier.projectGroups;

        expect(projectGroups, isNull);
      },
    );

    test(
      ".subscribeToProjectGroups() delegates to the receiveProjectGroupUpdates usecase",
      () {
        when(receiveProjectGroupUpdates.call())
            .thenAnswer((realInvocation) => const Stream.empty());

        projectGroupsNotifier.subscribeToProjectGroups();

        verify(receiveProjectGroupUpdates.call()).called(equals(1));
      },
    );

    test(
      ".subscribeToProjectGroups() subscribes to project groups updates",
      () async {
        final projectGroupsController = StreamController<List<ProjectGroup>>();

        when(receiveProjectGroupUpdates.call()).thenAnswer(
          (_) => projectGroupsController.stream,
        );

        await projectGroupsNotifier.subscribeToProjectGroups();

        expect(projectGroupsController.hasListener, isTrue);
      },
    );

    test(
      ".errorMessage provides an error description if project groups stream emits a PlatformException",
      () async {
        final projectGroupsController = BehaviorSubject<List<ProjectGroup>>();
        const errorMessage = 'errorMessage';

        when(receiveProjectGroupUpdates())
            .thenAnswer((_) => projectGroupsController.stream);

        final projectGroupsNotifier = ProjectGroupsNotifier(
          receiveProjectGroupUpdates,
          addProjectGroupUseCase,
          updateProjectGroupUseCase,
          deleteProjectGroupUseCase,
        );

        await projectGroupsNotifier.subscribeToProjectGroups();

        projectGroupsController.addError(PlatformException(
          message: errorMessage,
          code: 'test_code',
        ));

        bool hasErrorDescription;
        final metricsListener = expectAsyncUntil0(() async {
          hasErrorDescription =
              projectGroupsNotifier.errorMessage == errorMessage;

          if (hasErrorDescription) projectGroupsNotifier.dispose();
        }, () => hasErrorDescription);

        projectGroupsNotifier.addListener(metricsListener);
      },
    );

    test(
      ".errorMessage provides an error description if project groups stream emits an unknown Exception",
      () async {
        final projectGroupsController = BehaviorSubject<List<ProjectGroup>>();
        const errorMessage = CommonStrings.unknownErrorMessage;

        when(receiveProjectGroupUpdates())
            .thenAnswer((_) => projectGroupsController.stream);

        final projectGroupsNotifier = ProjectGroupsNotifier(
          receiveProjectGroupUpdates,
          addProjectGroupUseCase,
          updateProjectGroupUseCase,
          deleteProjectGroupUseCase,
        );

        await projectGroupsNotifier.subscribeToProjectGroups();

        projectGroupsController.addError(Exception());

        bool hasErrorDescription;
        final metricsListener = expectAsyncUntil0(() async {
          hasErrorDescription =
              projectGroupsNotifier.errorMessage == errorMessage;

          if (hasErrorDescription) projectGroupsNotifier.dispose();
        }, () => hasErrorDescription);

        projectGroupsNotifier.addListener(metricsListener);
      },
    );

    test(".deleteProjectGroup() delegates to the DeleteProjectGroupUseCase",
        () {
      projectGroupsNotifier.deleteProjectGroup(projectGroupId);

      verify(
        deleteProjectGroupUseCase(
          DeleteProjectGroupParam(projectGroupId: projectGroupId),
        ),
      ).called(1);
    });

    test(
        ".saveProjectGroup() delegates to the UpdateProjectGroupUseCase if the projectGroupId is not null",
        () {
      projectGroupsNotifier.saveProjectGroup(
        projectGroupId,
        projectGroupName,
        projectIds,
      );

      verify(
        updateProjectGroupUseCase(
          UpdateProjectGroupParam(
            projectGroupId,
            projectGroupName,
            projectIds,
          ),
        ),
      ).called(1);
    });

    test(
      ".saveProjectGroup() delegates to the AddProjectGroupUseCase if the projectGroupId is null",
      () {
        projectGroupsNotifier.saveProjectGroup(
          null,
          projectGroupName,
          projectIds,
        );

        verify(
          addProjectGroupUseCase(
            AddProjectGroupParam(
              projectGroupName: projectGroupName,
              projectIds: projectIds,
            ),
          ),
        ).called(1);
      },
    );
    test(".saveProjectGroup() returns true if completes successfully",
        () async {
      final result = await projectGroupsNotifier.saveProjectGroup(
        null,
        projectGroupName,
        projectIds,
      );

      expect(result, isTrue);
    });

    test(".saveProjectGroup() returns false if throws an Exception", () async {
      when(addProjectGroupUseCase(any)).thenThrow(Exception());

      final result = await projectGroupsNotifier.saveProjectGroup(
        null,
        projectGroupName,
        projectIds,
      );

      expect(result, isFalse);
    });

    test(
      ".generateActiveProjectGroupViewModel() update project selector view models",
      () {
        const testProjectId = 'testProjectId';
        const testProjectGroupId = 'testGroupId';

        final projectGroupsNotifier = ProjectGroupsNotifier(
          receiveProjectGroupUpdates,
          addProjectGroupUseCase,
          updateProjectGroupUseCase,
          deleteProjectGroupUseCase,
        );

        when(receiveProjectGroupUpdates()).thenAnswer(
          (_) => Stream.value([
            ProjectGroup(id: 'id', name: 'name', projectIds: const []),
            ProjectGroup(
                id: testProjectGroupId,
                name: 'name',
                projectIds: const [testProjectId]),
          ]),
        );

        projectGroupsNotifier.subscribeToProjectGroups();

        projectGroupsNotifier.updateProjects([
          ProjectModel(id: testProjectId, name: '1'),
        ], null);

        expect(
          projectGroupsNotifier.projectSelectorViewModels.first.isChecked,
          false,
        );

        List<ProjectGroup> oldProjectGroups;
        bool projectSelectorViewModelIsChecked = false;
        final projectGroupListener = expectAsyncUntil0(() {
          if (oldProjectGroups != projectGroupsNotifier.projectGroups) {
            oldProjectGroups = projectGroupsNotifier.projectGroups;

            projectGroupsNotifier.setActiveProjectGroup(
              testProjectGroupId,
            );

            final projectSelectorViewModel =
                projectGroupsNotifier.projectSelectorViewModels.first;
            projectSelectorViewModelIsChecked =
                projectSelectorViewModel.isChecked;

            projectGroupsNotifier.dispose();
          }
        }, () => projectSelectorViewModelIsChecked);

        projectGroupsNotifier.addListener(projectGroupListener);
      },
    );

    test(
      ".generateActiveProjectGroupViewModel() generate new active project group view model by id",
      () {
        const testProjectGroupId = 'testGroupId';

        final projectGroupsNotifier = ProjectGroupsNotifier(
          receiveProjectGroupUpdates,
          addProjectGroupUseCase,
          updateProjectGroupUseCase,
          deleteProjectGroupUseCase,
        );

        when(receiveProjectGroupUpdates()).thenAnswer(
          (_) => Stream.value([
            ProjectGroup(id: 'id', name: 'name', projectIds: const []),
            ProjectGroup(
              id: testProjectGroupId,
              name: 'name',
              projectIds: const [],
            ),
          ]),
        );

        projectGroupsNotifier.subscribeToProjectGroups();

        projectGroupsNotifier.updateProjects([
          ProjectModel(id: 'id', name: 'name'),
        ], null);

        expect(projectGroupsNotifier.activeProjectGroupDialogViewModel, isNull);

        List<ProjectGroup> oldProjects;
        bool activeProjectGroupDialogViewModelIsNotNull = false;
        final projectGroupListener = expectAsyncUntil0(() {
          if (oldProjects != projectGroupsNotifier.projectGroups) {
            oldProjects = projectGroupsNotifier.projectGroups;
            projectGroupsNotifier.setActiveProjectGroup(
              testProjectGroupId,
            );

            activeProjectGroupDialogViewModelIsNotNull =
                projectGroupsNotifier.activeProjectGroupDialogViewModel != null;

            projectGroupsNotifier.dispose();
          }
        }, () => activeProjectGroupDialogViewModelIsNotNull);

        projectGroupsNotifier.addListener(projectGroupListener);
      },
    );

    test(
      ".generateActiveProjectGroupViewModel() resets project name filter",
      () async {
        const testProjectGroupId = 'testGroupId';
        const filteredProjectName = 'filteredProjectName';
        const expectedFilteredProjectsLength = 1;
        final testProjects = [
          ProjectModel(id: 'id1', name: 'name'),
          ProjectModel(id: 'id2', name: filteredProjectName),
        ];

        final projectGroupsNotifier = ProjectGroupsNotifier(
          receiveProjectGroupUpdates,
          addProjectGroupUseCase,
          updateProjectGroupUseCase,
          deleteProjectGroupUseCase,
        );

        when(receiveProjectGroupUpdates()).thenAnswer(
          (_) => Stream.value([
            ProjectGroup(id: 'id', name: 'name', projectIds: const []),
            ProjectGroup(
              id: testProjectGroupId,
              name: 'name',
              projectIds: const [],
            ),
          ]),
        );

        projectGroupsNotifier.subscribeToProjectsNameFilter();

        projectGroupsNotifier.updateProjects(testProjects, null);

        projectGroupsNotifier.filterByProjectName(filteredProjectName);

        await Future.delayed(
          Duration(
              milliseconds: DurationConstants.debounce.inMilliseconds + 100),
        );

        expect(projectGroupsNotifier.projectSelectorViewModels.length,
            expectedFilteredProjectsLength);

        await projectGroupsNotifier.subscribeToProjectGroups();

        List<ProjectGroup> oldProjectGroups;
        bool isFilterReset = false;
        final projectGroupListener = expectAsyncUntil0(() {
          if (oldProjectGroups != projectGroupsNotifier.projectGroups) {
            oldProjectGroups = projectGroupsNotifier.projectGroups;

            projectGroupsNotifier.setActiveProjectGroup(
              testProjectGroupId,
            );

            isFilterReset =
                projectGroupsNotifier.projectSelectorViewModels.length ==
                    testProjects.length;

            projectGroupsNotifier.dispose();
          }
        }, () => isFilterReset);

        projectGroupsNotifier.addListener(projectGroupListener);
      },
    );

    test(
      ".toggleProjectCheckedStatus() adds the given projectId to the active project group dialog projectIds field if is checked",
      () {
        const testProjectGroupId = 'testGroupId';
        const testProjectId = 'testProjectId';

        final projectGroupsNotifier = ProjectGroupsNotifier(
          receiveProjectGroupUpdates,
          addProjectGroupUseCase,
          updateProjectGroupUseCase,
          deleteProjectGroupUseCase,
        );

        when(receiveProjectGroupUpdates()).thenAnswer(
          (_) => Stream.value([
            ProjectGroup(id: 'id', name: 'name', projectIds: const []),
            ProjectGroup(
              id: testProjectGroupId,
              name: 'name',
              projectIds: const [],
            ),
          ]),
        );

        projectGroupsNotifier.subscribeToProjectGroups();

        projectGroupsNotifier.updateProjects([
          ProjectModel(id: testProjectId, name: 'name'),
        ], null);

        List<ProjectGroup> oldProjectGroups;
        bool projectIdIsAdded = false;
        final projectGroupListener = expectAsyncUntil0(() {
          if (oldProjectGroups != projectGroupsNotifier.projectGroups) {
            oldProjectGroups = projectGroupsNotifier.projectGroups;

            projectGroupsNotifier.setActiveProjectGroup(testProjectGroupId);
            projectGroupsNotifier.toggleProjectCheckedStatus(
              projectId: testProjectId,
              isChecked: true,
            );

            final newActiveViewModel =
                projectGroupsNotifier.activeProjectGroupDialogViewModel;
            projectIdIsAdded =
                newActiveViewModel.selectedProjectIds.contains(testProjectId);

            projectGroupsNotifier.dispose();
          }
        }, () => projectIdIsAdded);

        projectGroupsNotifier.addListener(projectGroupListener);
      },
    );

    test(
      ".toggleProjectCheckedStatus() removes the given projectId from the active project group dialog projectIds field if is not checked",
      () {
        const testProjectGroupId = 'testGroupId';
        const testProjectId = 'testProjectId';

        final projectGroupsNotifier = ProjectGroupsNotifier(
          receiveProjectGroupUpdates,
          addProjectGroupUseCase,
          updateProjectGroupUseCase,
          deleteProjectGroupUseCase,
        );

        when(receiveProjectGroupUpdates()).thenAnswer(
          (_) => Stream.value([
            ProjectGroup(id: 'id', name: 'name', projectIds: const []),
            ProjectGroup(
              id: testProjectGroupId,
              name: 'name',
              projectIds: const [testProjectId],
            ),
          ]),
        );

        projectGroupsNotifier.subscribeToProjectGroups();

        projectGroupsNotifier.updateProjects([
          ProjectModel(id: testProjectId, name: 'name'),
        ], null);

        List<ProjectGroup> oldProjectGroups;
        bool projectIdIsRemoved = false;
        final projectGroupListener = expectAsyncUntil0(() {
          if (oldProjectGroups != projectGroupsNotifier.projectGroups) {
            oldProjectGroups = projectGroupsNotifier.projectGroups;

            projectGroupsNotifier.setActiveProjectGroup(
              testProjectGroupId,
            );
            projectGroupsNotifier.toggleProjectCheckedStatus(
              projectId: testProjectId,
              isChecked: false,
            );

            final newActiveViewModel =
                projectGroupsNotifier.activeProjectGroupDialogViewModel;
            projectIdIsRemoved =
                !newActiveViewModel.selectedProjectIds.contains(testProjectId);

            projectGroupsNotifier.dispose();
          }
        }, () => projectIdIsRemoved);

        projectGroupsNotifier.addListener(projectGroupListener);
      },
    );

    test(
      ".toggleProjectCheckedStatus() changes project selector view model is checked status to the given by id",
      () {
        const testProjectGroupId = 'testGroupId';
        const testProjectId = 'testProjectId';

        final projectGroupsNotifier = ProjectGroupsNotifier(
          receiveProjectGroupUpdates,
          addProjectGroupUseCase,
          updateProjectGroupUseCase,
          deleteProjectGroupUseCase,
        );

        when(receiveProjectGroupUpdates()).thenAnswer(
          (_) => Stream.value([
            ProjectGroup(id: 'id', name: 'name', projectIds: const []),
            ProjectGroup(
              id: testProjectGroupId,
              name: 'name',
              projectIds: const [],
            ),
          ]),
        );

        projectGroupsNotifier.subscribeToProjectGroups();

        projectGroupsNotifier.updateProjects([
          ProjectModel(id: testProjectId, name: 'name'),
        ], null);

        List<ProjectGroup> oldProjectGroups;
        bool projectSelectorIsChecked = false;
        final projectGroupListener = expectAsyncUntil0(() {
          if (oldProjectGroups != projectGroupsNotifier.projectGroups) {
            oldProjectGroups = projectGroupsNotifier.projectGroups;

            projectGroupsNotifier.setActiveProjectGroup(
              testProjectGroupId,
            );
            projectGroupsNotifier.toggleProjectCheckedStatus(
                projectId: testProjectId, isChecked: true);

            final projectSelectorViewModel =
                projectGroupsNotifier.projectSelectorViewModels.firstWhere(
              (project) => project.id == testProjectId,
            );
            projectSelectorIsChecked = projectSelectorViewModel.isChecked;

            projectGroupsNotifier.dispose();
          }
        }, () => projectSelectorIsChecked);

        projectGroupsNotifier.addListener(projectGroupListener);
      },
    );

    test(".deleteProjectGroup() returns true if completes successfully",
        () async {
      final result = await projectGroupsNotifier.deleteProjectGroup(
        projectGroupId,
      );

      expect(result, isTrue);
    });

    test(".deleteProjectGroup() returns false if throws an Exception",
        () async {
      when(deleteProjectGroupUseCase(any)).thenThrow(Exception());

      final result =
          await projectGroupsNotifier.deleteProjectGroup(projectGroupId);

      expect(result, isFalse);
    });

    test(
      ".saveProjectGroup() sets the firestore error message if the AddProjectGroupUseCase throws",
      () async {
        when(addProjectGroupUseCase(any)).thenThrow(Exception());

        await projectGroupsNotifier.saveProjectGroup(
          null,
          projectGroupName,
          projectIds,
        );

        expect(
          projectGroupsNotifier.projectGroupSavingErrorMessage,
          equals(CommonStrings.unknownErrorMessage),
        );
      },
    );

    test(
      ".saveProjectGroup() sets the firestore error message if the UpdateProjectGroupUseCase throws",
      () async {
        when(updateProjectGroupUseCase(any)).thenThrow(Exception());

        await projectGroupsNotifier.saveProjectGroup(
          projectGroupId,
          projectGroupName,
          projectIds,
        );

        expect(
          projectGroupsNotifier.projectGroupSavingErrorMessage,
          equals(CommonStrings.unknownErrorMessage),
        );
      },
    );

    test(
      ".deleteProjectGroup() sets the firestore error message if the DeleteProjectGroupUseCase throws",
      () async {
        when(deleteProjectGroupUseCase(any)).thenThrow(Exception());

        await projectGroupsNotifier.deleteProjectGroup(projectGroupId);

        expect(
          projectGroupsNotifier.projectGroupSavingErrorMessage,
          equals(CommonStrings.unknownErrorMessage),
        );
      },
    );

    test(
      ".resetFirestoreWriteErrorMessage() sets an error message to null",
      () async {
        when(addProjectGroupUseCase(any)).thenThrow(Exception());

        await projectGroupsNotifier.saveProjectGroup(
          null,
          projectGroupName,
          projectIds,
        );

        expect(
          projectGroupsNotifier.projectGroupSavingErrorMessage,
          equals(CommonStrings.unknownErrorMessage),
        );

        projectGroupsNotifier.resetProjectGroupSavingError();

        expect(projectGroupsNotifier.projectGroupSavingErrorMessage, isNull);
      },
    );

    test(
      ".unsubscribeFromProjectGroups() cancels all created subscriptions and clear project groups",
      () async {
        when(receiveProjectGroupUpdates()).thenAnswer(
          (_) => Stream.value([
            ProjectGroup(id: 'id', name: 'name', projectIds: const []),
            ProjectGroup(id: 'id', name: 'name', projectIds: const []),
          ]),
        );

        final projectGroupsNotifier = ProjectGroupsNotifier(
          receiveProjectGroupUpdates,
          addProjectGroupUseCase,
          updateProjectGroupUseCase,
          deleteProjectGroupUseCase,
        );

        await expectLater(
          projectGroupsNotifier.subscribeToProjectGroups(),
          completes,
        );

        expect(projectGroupsNotifier.projectGroups, isNotNull);

        await projectGroupsNotifier.unsubscribeFromProjectGroups();

        expect(projectGroupsNotifier.projectGroups, isNull);
      },
    );

    test(
      ".dispose() cancels all created subscriptions",
      () async {
        final projectGroupsNotifier = ProjectGroupsNotifier(
          receiveProjectGroupUpdates,
          addProjectGroupUseCase,
          updateProjectGroupUseCase,
          deleteProjectGroupUseCase,
        );

        final projectGroupsController = StreamController<List<ProjectGroup>>();

        when(receiveProjectGroupUpdates()).thenAnswer(
          (_) => projectGroupsController.stream,
        );

        await projectGroupsNotifier.subscribeToProjectGroups();

        expect(projectGroupsController.hasListener, isTrue);

        projectGroupsNotifier.dispose();

        expect(projectGroupsController.hasListener, isFalse);
      },
    );
  });
}

class AddProjectGroupUseCaseMock extends Mock
    implements AddProjectGroupUseCase {}

class UpdateProjectGroupUseCaseMock extends Mock
    implements UpdateProjectGroupUseCase {}

class DeleteProjectGroupUseCaseMock extends Mock
    implements DeleteProjectGroupUseCase {}

class ReceiveProjectGroupUpdatesMock extends Mock
    implements ReceiveProjectGroupUpdates {}
