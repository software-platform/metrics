import 'package:flutter/material.dart';
import 'package:metrics/common/presentation/metrics_theme/config/color_config.dart';

/// A class that holds the common text field styles for application themes.
class TextFieldConfig {
  /// A [TextStyle] of the error message to use in the text field.
  static const TextStyle errorStyle = TextStyle(
    color: ColorConfig.accentColor,
    fontSize: 16.0,
    height: 1.0,
  );

  /// A default [OutlineInputBorder] of the text field.
  static const border = OutlineInputBorder(
    borderSide: BorderSide.none,
  );

  /// An [OutlineInputBorder] to display when
  /// the text filed is showing an error.
  static const errorBorder = OutlineInputBorder(
    borderSide: BorderSide(color: ColorConfig.accentColor),
  );
}
