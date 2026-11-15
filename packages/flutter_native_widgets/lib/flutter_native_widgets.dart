/// Native widgets that render the running platform's own controls.
///
/// - iOS: the running release's UIKit controls and bars, Liquid Glass on
///   iOS 26 and later, including the iPhone Duo vertical bar.
/// - Android and elsewhere: Material widgets.
///
/// ```dart
/// NativeApp(
///   theme: NativeThemeData(primaryColor: Colors.teal),
///   home: NativeScaffold(
///     appBar: NativeAppBar(title: 'Inbox', largeTitle: true),
///     body: ListView(children: messages),
///   ),
/// )
/// ```
library;

// Platform utilities
export 'src/core/platform_info.dart';
export 'src/core/native_style.dart';
export 'src/devices/duo/duo_layout.dart' show DuoPose, DuoPoseScope;

// Animation utilities
export 'src/core/animation.dart';

// Styles
export 'src/core/theme/native_theme.dart';
export 'src/style/sf_symbol.dart';
export 'src/style/native_icon.dart';

// Widgets
export 'src/app/native_app.dart';
export 'src/navigation/navigator/native_navigator.dart'
    show NativeNavigator, NativePage;

// Fixed toolbar chrome (installed automatically by NativeApp; exported so
// apps with their own MaterialApp/CupertinoApp can wrap their builder)
export 'src/navigation/chrome/native_toolbar_host.dart';
export 'src/navigation/chrome/toolbar_registry.dart';
export 'src/navigation/app_bar/native_app_bar.dart';
export 'src/navigation/tab_bar/native_bottom_navigation_bar.dart';
export 'src/navigation/search/native_tab_search.dart';
export 'src/controls/button/native_button.dart';
export 'src/controls/switch/native_switch.dart';
export 'src/controls/checkbox/native_checkbox.dart';
export 'src/controls/radio/native_radio.dart';
export 'src/content/card/native_card.dart';
export 'src/content/badge/native_badge.dart';
export 'src/overlays/tooltip/native_tooltip.dart';
export 'src/controls/slider/native_slider.dart';
export 'src/controls/segmented_control/native_segmented_control.dart';
export 'src/overlays/alert_dialog/native_alert_dialog.dart';
export 'src/overlays/popup_menu/native_popup_menu_button.dart';
export 'src/overlays/context_menu/native_context_menu.dart';
export 'src/navigation/scaffold/native_scaffold.dart';
export 'src/navigation/drawer/native_drawer.dart';
export 'src/navigation/app_bar/native_app_bar_action.dart';
export 'src/overlays/snackbar/native_snackbar.dart';
export 'src/controls/pickers/native_date_picker.dart';
export 'src/controls/pickers/native_time_picker.dart';
export 'src/content/list_tile/native_list_tile.dart';
export 'src/controls/text_field/native_text_field.dart';
export 'src/controls/text_field/native_text_form_field.dart';
export 'src/navigation/tab_bar/native_tab_view.dart';
export 'src/navigation/scaffold/native_floating_action_button.dart';
export 'src/content/form_section/native_form_section.dart';
export 'src/content/expansion_tile/native_expansion_tile.dart';
export 'src/content/blur_view/native_blur_view.dart';

export 'src/overlays/action_sheet/native_action_sheet.dart';
export 'src/overlays/bottom_sheet/native_bottom_sheet.dart';
export 'src/overlays/filter_sheet/native_filter_sheet.dart';
export 'src/overlays/native_sheet/native_sheet.dart';
export 'src/overlays/overlay_container/native_overlay_container.dart';
export 'src/controls/pickers/native_inline_date_picker.dart';
export 'src/style/native_fonts.dart';

export 'src/navigation/search/native_navigation_search_bar.dart';
