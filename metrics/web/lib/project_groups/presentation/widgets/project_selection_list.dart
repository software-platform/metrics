import 'package:flutter/material.dart';
import 'package:metrics/base/presentation/widgets/text_placeholder.dart';
import 'package:metrics/common/presentation/widgets/loading_placeholder.dart';
import 'package:metrics/dashboard/presentation/strings/dashboard_strings.dart';
import 'package:metrics/project_groups/presentation/state/project_groups_notifier.dart';
import 'package:metrics/project_groups/presentation/widgets/project_selection_list_tile.dart';
import 'package:provider/provider.dart';

/// A widget that displays the list of [ProjectSelectionListTile] for project selection.
class ProjectSelectionList extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    return Consumer<ProjectGroupsNotifier>(
      builder: (_, projectGroupsNotifier, __) {
        if (projectGroupsNotifier.projectsErrorMessage != null) {
          return TextPlaceholder(
            text: projectGroupsNotifier.projectsErrorMessage,
          );
        }

        final projectSelectorViewModels =
            projectGroupsNotifier.projectSelectorViewModels;

        if (projectSelectorViewModels == null) {
          return const LoadingPlaceholder();
        }

        if (projectSelectorViewModels.isEmpty) {
          return const TextPlaceholder(
            text: DashboardStrings.noConfiguredProjects,
          );
        }

        return ListView.builder(
          itemCount: projectSelectorViewModels.length,
          itemBuilder: (context, index) {
            final projectSelectorViewModel = projectSelectorViewModels[index];

            return ProjectSelectionListTile(
              projectSelectorViewModel: projectSelectorViewModel,
            );
          },
        );
      },
    );
  }
}
