/// A class that represents the data of the project group to display
/// inside a delete dialog.
class SelectedProjectGroupDeleteDialogViewModel {
  /// A unique identifier of the project.
  final String id;

  /// A name of the project.
  final String name;

  /// Creates the [SelectedProjectGroupDeleteDialogViewModel].
  SelectedProjectGroupDeleteDialogViewModel({
    this.id,
    this.name,
  });
}
