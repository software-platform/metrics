// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:metrics/common/presentation/scaffold/widget/metrics_scaffold.dart';
import 'package:metrics/common/presentation/strings/common_strings.dart';
import 'package:metrics/common/presentation/toast/widgets/negative_toast.dart';
import 'package:metrics/common/presentation/toast/widgets/toast.dart';
import 'package:metrics/project_groups/domain/entities/project_group.dart';
import 'package:metrics/project_groups/presentation/state/project_groups_notifier.dart';
import 'package:metrics/project_groups/presentation/widgets/project_group_view.dart';
import 'package:provider/provider.dart';

/// A page that displays the list of [ProjectGroup]s and provides an ability
/// to add a new [ProjectGroup].
class ProjectGroupPage extends StatefulWidget {
  /// Creates a new instance of the [ProjectGroupPage].
  const ProjectGroupPage({Key key}) : super(key: key);

  @override
  _ProjectGroupPageState createState() => _ProjectGroupPageState();
}

class _ProjectGroupPageState extends State<ProjectGroupPage> {
  /// A [ProjectGroupsNotifier] needed to remove added listeners
  /// in the [dispose] method.
  ProjectGroupsNotifier _projectGroupsNotifier;

  @override
  void initState() {
    super.initState();
    _subscribeToProjectGroupsErrors();
  }

  @override
  Widget build(BuildContext context) {
    return MetricsScaffold(
      title: CommonStrings.projectGroups,
      padding: const EdgeInsets.only(top: 40.0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProjectGroupView(),
          ],
        ),
      ),
    );
  }

  /// Subscribes to project groups errors.
  void _subscribeToProjectGroupsErrors() {
    _projectGroupsNotifier = Provider.of<ProjectGroupsNotifier>(
      context,
      listen: false,
    );

    _projectGroupsNotifier.addListener(_projectGroupsErrorListener);
  }

  /// Shows the [NegativeToast] with an error message
  /// if the project groups error message is not null.
  void _projectGroupsErrorListener() {
    final errorMessage = _projectGroupsNotifier.projectGroupsErrorMessage;

    if (errorMessage != null) {
      showToast(
        context,
        NegativeToast(message: errorMessage),
      );
    }
  }

  @override
  void dispose() {
    _projectGroupsNotifier.removeListener(_projectGroupsErrorListener);
    super.dispose();
  }
}
