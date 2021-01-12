import 'package:flutter/material.dart';

/// A stub implementation of the [RouterDelegate].
class RouterDelegateStub extends RouterDelegate with ChangeNotifier {
  /// A [Widget] to display.
  final Widget body;

  /// Creates a new instance of the [RouterDelegateStub].
  RouterDelegateStub({this.body});

  @override
  Widget build(BuildContext context) {
    return body;
  }

  @override
  Future<bool> popRoute() async {
    return true;
  }

  @override
  Future<void> setNewRoutePath(dynamic configuration) async {}
}
