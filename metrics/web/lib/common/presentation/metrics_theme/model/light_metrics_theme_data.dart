import 'package:flutter/material.dart';
import 'package:metrics/common/presentation/button/theme/attention_level/metrics_button_attention_level.dart';
import 'package:metrics/common/presentation/button/theme/style/metrics_button_style.dart';
import 'package:metrics/common/presentation/button/theme/theme_data/metrics_button_theme_data.dart';
import 'package:metrics/common/presentation/dropdown/theme/theme_data/dropdown_item_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/config/color_config.dart';
import 'package:metrics/common/presentation/metrics_theme/config/text_style_config.dart';
import 'package:metrics/common/presentation/metrics_theme/model/add_project_group_card/attention_level/add_project_group_card_attention_level.dart';
import 'package:metrics/common/presentation/metrics_theme/model/add_project_group_card/style/add_project_group_card_style.dart';
import 'package:metrics/common/presentation/metrics_theme/model/add_project_group_card/theme_data/add_project_group_card_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/build_results_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/circle_percentage/attention_level/circle_percentage_attention_level.dart';
import 'package:metrics/common/presentation/metrics_theme/model/circle_percentage/style/circle_percentage_style.dart';
import 'package:metrics/common/presentation/metrics_theme/model/circle_percentage/theme_data/circle_percentage_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/delete_dialog_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/dropdown_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/login_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/metrics_widget_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/metrics_table/theme_data/metrics_table_header_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/metrics_table/theme_data/project_metrics_table_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/metrics_table/theme_data/project_metrics_tile_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/metrics_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/project_build_status/attention_level/project_build_status_attention_level.dart';
import 'package:metrics/common/presentation/metrics_theme/model/project_build_status/style/project_build_status_style.dart';
import 'package:metrics/common/presentation/metrics_theme/model/project_build_status/theme_data/project_build_status_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/project_group_card_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/project_group_dialog_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/scorecard/theme_data/scorecard_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/shimmer_placeholder/theme_data/shimmer_placeholder_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/sparkline/theme_data/sparkline_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/text_field_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/user_menu_theme_data.dart';
import 'package:metrics/common/presentation/text_placeholder/theme/theme_data/text_placeholder_theme_data.dart';
import 'package:metrics/common/presentation/toast/theme/attention_level/toast_attention_level.dart';
import 'package:metrics/common/presentation/toast/theme/style/toast_style.dart';
import 'package:metrics/common/presentation/toast/theme/theme_data/toast_theme_data.dart';
import 'package:metrics/common/presentation/toggle/theme/theme_data/toggle_theme_data.dart';
import 'package:metrics/common/presentation/widgets/metrics_text_style.dart';

/// Stores the theme data for light metrics theme.
class LightMetricsThemeData extends MetricsThemeData {
  static const Color scaffoldColor = Colors.white;
  static const Color inputColor = Color(0xFFF5F8FA);
  static const Color inputHoverColor = Color(0xfffafbfc);
  static const inputFocusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(4.0)),
    borderSide: BorderSide(color: _inputFocusedBorderColor),
  );

  static const Color _dropdownHoverColor = Color(0xff878799);
  static const Color _focusedBorderColor = Colors.blue;
  static const Color _inactiveBackgroundColor = Color(0xFFEEEEEE);
  static const Color _inactiveColor = Color(0xFFBDBDBD);
  static const Color _inactiveButtonColor = Color(0xFFf0f0f5);
  static const Color _inactiveButtonHoverColor = Color(0xFFcccccc);
  static const Color _inactiveTextColor = Color(0xff040d14);
  static const Color _cardHoverColor = Color(0xFF212124);
  static const Color _borderColor = Color(0xFF2d2d33);
  static const Color _borderHoverColor = Color(0xFF37373F);
  static const Color _tileBorderColor = Color(0xFFE0E0E0);
  static const Color _tableHeaderColor = Color(0xFF79858b);
  static const Color _inactiveToggleColor = Color(0xFF88889b);
  static const Color _inactiveToggleHoverColor = Color(0xFF5d5d6a);
  static const Color _textPlaceholderColor = Color(0xFFdcdce3);
  static const Color _addProjectGroupCardBackgroundColor = Color(0xffd7faf4);
  static const Color _addProjectGroupCardHoverColor = Color(0xffc3f5eb);
  static const Color _userMenuShadowColor = Color.fromRGBO(0, 0, 0, 0.32);
  static const Color _hoverBorderColor = Color(0xffb6b6ba);
  static const Color _activeBorderColor = Color(0xff6d6d75);
  static const Color _inputColor = Color(0xfff5f8fa);
  static const Color _openedButtonInactiveColor = Color(0xfffafbfc);
  static const TextStyle _defaultDropdownTextStyle = TextStyle(
    fontSize: 16.0,
    color: _inactiveTextColor,
  );

  static const Color _positiveToastBackgroundColor = Color(0xffe1faf4);
  static const Color _positiveToastTextColor = Color(0xCC20CE9A);
  static const Color _negativeToastBackgroundColor = Color(0xffffede5);
  static const Color _negativeToastTextColor = Color(0xCCF45531);

  static const Color _inputFocusedBorderColor = Color(0xff6d6d75);

  /// A [TextStyle] of the dialog title.
  static const TextStyle _dialogTitleTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 26.0,
    fontWeight: FontWeight.w500,
  );

  /// Creates the light theme with the default widget theme configuration.
  const LightMetricsThemeData()
      : super(
          metricsWidgetTheme: const MetricsWidgetThemeData(
            primaryColor: ColorConfig.primaryColor,
            accentColor: ColorConfig.primaryTranslucentColor,
            backgroundColor: Colors.white,
            textStyle: TextStyle(
              color: ColorConfig.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          buildResultTheme: const BuildResultsThemeData(
            canceledColor: ColorConfig.accentColor,
            successfulColor: ColorConfig.primaryColor,
            failedColor: ColorConfig.accentColor,
          ),
          projectGroupCardTheme: const ProjectGroupCardThemeData(
            borderColor: _borderColor,
            hoverColor: _cardHoverColor,
            backgroundColor: scaffoldColor,
            accentColor: ColorConfig.accentColor,
            primaryColor: ColorConfig.primaryColor,
            titleStyle: MetricsTextStyle(
              color: Colors.black,
              lineHeightInPixels: 26.0,
              fontSize: 22.0,
              fontWeight: FontWeight.w500,
            ),
            subtitleStyle: MetricsTextStyle(
              color: ColorConfig.secondaryTextColor,
              lineHeightInPixels: 16.0,
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          addProjectGroupCardTheme: const AddProjectGroupCardThemeData(
            attentionLevel: AddProjectGroupCardAttentionLevel(
              positive: AddProjectGroupCardStyle(
                backgroundColor: _addProjectGroupCardBackgroundColor,
                iconColor: ColorConfig.primaryColor,
                hoverColor: _addProjectGroupCardHoverColor,
                labelStyle: MetricsTextStyle(
                  color: ColorConfig.primaryColor,
                  lineHeightInPixels: 20.0,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              inactive: AddProjectGroupCardStyle(
                backgroundColor: _inactiveBackgroundColor,
                hoverColor: _inactiveBackgroundColor,
                iconColor: scaffoldColor,
                labelStyle: MetricsTextStyle(
                  color: scaffoldColor,
                  lineHeightInPixels: 20.0,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          deleteDialogTheme: const DeleteDialogThemeData(
            backgroundColor: scaffoldColor,
            closeIconColor: Colors.black,
            titleTextStyle: _dialogTitleTextStyle,
            contentTextStyle: MetricsTextStyle(
              fontSize: 16.0,
              color: Colors.black,
              lineHeightInPixels: 24.0,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.14,
            ),
          ),
          projectGroupDialogTheme: const ProjectGroupDialogThemeData(
            primaryColor: ColorConfig.primaryColor,
            closeIconColor: Colors.black,
            contentBorderColor: _borderColor,
            titleTextStyle: _dialogTitleTextStyle,
            uncheckedProjectTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
            ),
            checkedProjectTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            counterTextStyle: TextStyleConfig.captionTextStyle,
            errorTextStyle: TextStyle(color: ColorConfig.accentColor),
          ),
          inactiveWidgetTheme: const MetricsWidgetThemeData(
            primaryColor: _inactiveColor,
            accentColor: Colors.transparent,
            backgroundColor: _inactiveBackgroundColor,
            textStyle: TextStyle(
              color: Colors.grey,
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          metricsButtonTheme: const MetricsButtonThemeData(
            buttonAttentionLevel: MetricsButtonAttentionLevel(
              positive: MetricsButtonStyle(
                color: ColorConfig.primaryColor,
                hoverColor: ColorConfig.primaryButtonHoverColor,
                elevation: 0.0,
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              neutral: MetricsButtonStyle(
                color: _inactiveButtonColor,
                hoverColor: _inactiveButtonHoverColor,
                elevation: 0.0,
                labelStyle: TextStyle(
                  color: _inactiveTextColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              negative: MetricsButtonStyle(
                color: ColorConfig.accentColor,
                hoverColor: ColorConfig.accentButtonHoverColor,
                elevation: 0.0,
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              inactive: MetricsButtonStyle(
                color: _inactiveButtonColor,
                elevation: 0.0,
                labelStyle: TextStyle(
                  color: _inactiveButtonHoverColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          textFieldTheme: const TextFieldThemeData(
            focusColor: inputHoverColor,
            hoverBorderColor: _borderHoverColor,
            textStyle: TextStyle(
              color: _inactiveTextColor,
              fontSize: 16.0,
            ),
          ),
          dropdownTheme: const DropdownThemeData(
            backgroundColor: Colors.white,
            openedButtonBackgroundColor: _openedButtonInactiveColor,
            hoverBackgroundColor: _openedButtonInactiveColor,
            hoverBorderColor: _hoverBorderColor,
            openedButtonBorderColor: _activeBorderColor,
            closedButtonBackgroundColor: _inputColor,
            closedButtonBorderColor: _inputColor,
            textStyle: _defaultDropdownTextStyle,
          ),
          dropdownItemTheme: const DropdownItemThemeData(
            backgroundColor: Colors.white,
            hoverColor: _dropdownHoverColor,
            textStyle: TextStyle(
              fontSize: 16.0,
              color: _inactiveTextColor,
            ),
          ),
          loginTheme: const LoginThemeData(
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 26.0,
              fontWeight: FontWeight.bold,
            ),
            loginOptionButtonStyle: MetricsButtonStyle(
              color: Colors.grey,
              hoverColor: Colors.black26,
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          projectMetricsTableTheme: const ProjectMetricsTableThemeData(
            metricsTableHeaderTheme: MetricsTableHeaderThemeData(
              textStyle: TextStyle(
                color: _tableHeaderColor,
                fontWeight: FontWeight.w200,
              ),
            ),
            projectMetricsTileTheme: ProjectMetricsTileThemeData(
              borderColor: _tileBorderColor,
              textStyle: TextStyle(fontSize: 22.0),
            ),
          ),
          buildNumberScorecardTheme: const ScorecardThemeData(),
          performanceSparklineTheme: const SparklineThemeData(),
          projectBuildStatusTheme: const ProjectBuildStatusThemeData(
            attentionLevel: ProjectBuildStatusAttentionLevel(
              positive: ProjectBuildStatusStyle(
                backgroundColor: ColorConfig.primaryTranslucentColor,
              ),
              negative: ProjectBuildStatusStyle(
                backgroundColor: ColorConfig.accentTranslucentColor,
              ),
              unknown: ProjectBuildStatusStyle(
                backgroundColor: ColorConfig.inactiveColor,
              ),
            ),
          ),
          toggleTheme: const ToggleThemeData(
            activeColor: ColorConfig.primaryColor,
            activeHoverColor: ColorConfig.primaryHoverColor,
            inactiveColor: _inactiveToggleColor,
            inactiveHoverColor: _inactiveToggleHoverColor,
          ),
          toastTheme: const ToastThemeData(
            toastAttentionLevel: ToastAttentionLevel(
              positive: ToastStyle(
                backgroundColor: _positiveToastBackgroundColor,
                textStyle: TextStyle(
                  color: _positiveToastTextColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              negative: ToastStyle(
                backgroundColor: _negativeToastBackgroundColor,
                textStyle: TextStyle(
                  color: _negativeToastTextColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
          ),
          userMenuTheme: const UserMenuThemeData(
            backgroundColor: Colors.white,
            dividerColor: scaffoldColor,
            shadowColor: _userMenuShadowColor,
            contentTextStyle: TextStyle(
              color: _inactiveTextColor,
              fontSize: 16.0,
              height: 1.0,
            ),
          ),
          textPlaceholderTheme: const TextPlaceholderThemeData(
            textStyle: TextStyle(
              color: _textPlaceholderColor,
              fontSize: 14.0,
            ),
          ),
          inputPlaceholderTheme: const ShimmerPlaceholderThemeData(
            backgroundColor: inputColor,
            shimmerColor: ColorConfig.shimmerColor,
          ),
          circlePercentageTheme: const CirclePercentageThemeData(
            attentionLevel: CirclePercentageAttentionLevel(
              positive: CirclePercentageStyle(
                strokeColor: ColorConfig.primaryTranslucentColor,
                backgroundColor: ColorConfig.primaryTranslucentColor,
                valueColor: ColorConfig.primaryColor,
                valueStyle: TextStyle(
                  color: ColorConfig.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              negative: CirclePercentageStyle(
                strokeColor: ColorConfig.accentTranslucentColor,
                backgroundColor: ColorConfig.accentTranslucentColor,
                valueColor: ColorConfig.accentColor,
                valueStyle: TextStyle(
                  color: ColorConfig.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              neutral: CirclePercentageStyle(
                strokeColor: ColorConfig.yellowTranslucent,
                backgroundColor: ColorConfig.yellowTranslucent,
                valueColor: ColorConfig.yellow,
                valueStyle: TextStyle(
                  color: ColorConfig.yellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              inactive: CirclePercentageStyle(
                strokeColor: _inactiveBackgroundColor,
                backgroundColor: _inactiveBackgroundColor,
                valueColor: _focusedBorderColor,
                valueStyle: TextStyle(
                  color: _inactiveColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
            ),
          ),
        );
}
