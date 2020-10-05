import 'package:flutter/material.dart';
import 'package:metrics/common/presentation/graph_indicator/theme/attention_level/graph_indicator_attention_level.dart';
import 'package:metrics/common/presentation/graph_indicator/theme/style/graph_indicator_style.dart';
import 'package:metrics/common/presentation/graph_indicator/theme/theme_data/graph_indicator_theme_data.dart';
import 'package:metrics/common/presentation/graph_indicator/widgets/graph_indicator.dart';

/// A [GraphIndicator] widget that applies
/// the [GraphIndicatorAttentionLevel.failed] indicator style
/// from the [GraphIndicatorThemeData].
class FailedGraphIndicator extends GraphIndicator {
  /// Creates a new instance of the [FailedGraphIndicator].
  const FailedGraphIndicator({Key key}) : super(key: key);

  @override
  GraphIndicatorStyle selectStyle(GraphIndicatorAttentionLevel attentionLevel) {
    return attentionLevel.failed;
  }
}
