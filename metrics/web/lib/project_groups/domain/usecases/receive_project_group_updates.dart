import 'package:metrics/project_groups/domain/entities/project_group.dart';
import 'package:metrics/common/domain/usecases/usecase.dart';
import 'package:metrics/project_groups/domain/repositories/project_group_repository.dart';

/// Provides an the ability to receive [ProjectGroup]s updates.
class ReceiveProjectGroupUpdates
    implements UseCase<Stream<List<ProjectGroup>>, void> {
  /// A repository, that gives an ability to receive a project groups updates.
  final ProjectGroupRepository _repository;

  /// Creates the [ReceiveProjectGroupUpdates] use case with the given [ProjectGroupRepository].
  ///
  /// Throws an ArgumentError if the [ProjectGroupRepository] is `null`.
  ReceiveProjectGroupUpdates(this._repository) {
    ArgumentError.checkNotNull(_repository, '_repository');
  }

  @override
  Stream<List<ProjectGroup>> call([_]) {
    return _repository.projectGroupsStream();
  }
}
