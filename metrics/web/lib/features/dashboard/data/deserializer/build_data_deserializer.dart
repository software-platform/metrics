import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metrics_core/metrics_core.dart';

class BuildDataDeserializer {
  /// Creates the [BuildData] instance from the [json] and it's [id].
  static BuildData fromJson(Map<String, dynamic> json, String id) {
    final buildResultValue = json['buildStatus'] as String;
    final durationMilliseconds = json['duration'] as int;
    final buildStatus = BuildStatus.values.firstWhere(
      (element) => '$element' == buildResultValue,
      orElse: () => null,
    );

    return BuildData(
      id: id,
      startedAt: (json['startedAt'] as Timestamp).toDate(),
      buildStatus: buildStatus,
      duration: Duration(milliseconds: durationMilliseconds),
      workflowName: json['workflow'] as String,
      url: json['url'] as String,
      coverage: Percent(json['coverage'] as double),
    );
  }
}
