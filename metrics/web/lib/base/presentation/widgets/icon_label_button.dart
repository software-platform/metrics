import 'package:flutter/material.dart';
import 'package:metrics/base/presentation/widgets/tappable_area.dart';

/// A widget that displays the button with given [icon] and [label] widgets.
class IconLabelButton extends StatelessWidget {
  /// The callback that is called when the button is tapped.
  final VoidCallback onPressed;

  /// The padding around this button.
  final EdgeInsets contentPadding;

  /// The builder of this button's icon.
  final HoverWidgetBuilder icon;

  /// The builder of this button's label.
  final HoverWidgetBuilder label;

  /// The padding around the [icon].
  final EdgeInsets iconPadding;

  /// Creates a new instance of the [IconLabelButton].
  ///
  /// Both [iconPadding] and [contentPadding] defaults to [EdgeInsets.zero].
  ///
  /// The [label] and [icon] must not be null.
  const IconLabelButton({
    Key key,
    @required this.label,
    @required this.icon,
    this.iconPadding = EdgeInsets.zero,
    this.contentPadding = EdgeInsets.zero,
    this.onPressed,
  })  : assert(label != null),
        assert(icon != null),
        assert(contentPadding != null),
        assert(iconPadding != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return TappableArea(
      onTap: onPressed,
      hitTestBehavior: HitTestBehavior.opaque,
      builder: (context, isHovered, _) {
        return Padding(
          padding: contentPadding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: iconPadding,
                child: icon(context, isHovered),
              ),
              label(context, isHovered),
            ],
          ),
        );
      },
    );
  }
}
