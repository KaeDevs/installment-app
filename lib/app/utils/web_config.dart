import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import '../utils/responsive.dart';

/// Web-specific optimizations and configurations
class WebConfig {
  /// Check if running on web platform
  static bool get isWeb => kIsWeb;

  /// Get optimal layout configuration for web
  static Map<String, dynamic> getWebLayoutConfig(BuildContext context) {
    return {
      'useFixedNavigation': Responsive.isDesktop(context),
      'showSidebar': Responsive.isDesktop(context),
      'useGridLayout': !Responsive.isMobile(context),
      'maxContentWidth': Responsive.isDesktop(context) ? 1200.0 : null,
      'sidebarWidth': Responsive.getSidebarWidth(context),
    };
  }

  /// Web-optimized scroll behavior
  static ScrollBehavior get scrollBehavior {
    return const MaterialScrollBehavior().copyWith(
      scrollbars: true, // Show scrollbars on web
      overscroll: false, // Disable overscroll glow
      physics: const ClampingScrollPhysics(),
    );
  }

  /// Web keyboard shortcuts
  static Map<LogicalKeySet, Intent> getWebKeyboardShortcuts() {
    return {
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): 
          const ActivateIntent(),
      LogicalKeySet(LogicalKeyboardKey.escape): 
          const DismissIntent(),
      LogicalKeySet(LogicalKeyboardKey.f5): 
          const ActivateIntent(),
    };
  }

  /// SEO and web metadata
  static Map<String, String> getWebMetadata() {
    return {
      'title': 'Installment Tracker - Manage Daily Loan Payments',
      'description': 'Professional loan and installment tracking application. '
          'Manage daily payments, track progress, and organize borrower information.',
      'keywords': 'loan tracker, installment, payment tracking, financial management',
      'author': 'KaeDevs',
      'viewport': 'width=device-width, initial-scale=1.0',
    };
  }

  /// Web-specific theme adjustments
  static ThemeData adjustThemeForWeb(ThemeData baseTheme, BuildContext context) {
    if (!isWeb) return baseTheme;

    return baseTheme.copyWith(
      // Adjust scroll behavior for web
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all(true),
        trackVisibility: WidgetStateProperty.all(true),
        thickness: WidgetStateProperty.all(8),
        radius: const Radius.circular(4),
        thumbColor: WidgetStateProperty.all(
          baseTheme.primaryColor.withOpacity(0.5),
        ),
        trackColor: WidgetStateProperty.all(
          baseTheme.primaryColor.withOpacity(0.1),
        ),
      ),
      
      // Optimize text selection for web
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: baseTheme.primaryColor,
        selectionColor: baseTheme.primaryColor.withOpacity(0.3),
        selectionHandleColor: baseTheme.primaryColor,
      ),
      
      // Web-optimized tooltips
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
        waitDuration: const Duration(milliseconds: 500),
      ),
      
      // Optimize buttons for web interaction
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: baseTheme.elevatedButtonTheme.style?.copyWith(
          mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return baseTheme.primaryColor.withOpacity(0.1);
            }
            return null;
          }),
        ),
      ),
    );
  }

  /// Web performance optimizations
  static Map<String, dynamic> getPerformanceSettings() {
    return {
      'enableSemantics': true,
      'debugShowCheckedModeBanner': false,
      'useCanvasKit': true, // Better text rendering
      'enableSkiaRenderer': true,
    };
  }

  /// Web accessibility features
  static Map<String, dynamic> getAccessibilitySettings() {
    return {
      'highContrast': false,
      'largeText': false,
      'screenReader': true,
      'keyboardNavigation': true,
    };
  }
}

/// Web-specific route information parser for URL handling
class WebRouteInformationParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) {
    return Future.value(routeInformation.uri.path);
  }

  @override
  RouteInformation restoreRouteInformation(String path) {
    return RouteInformation(uri: Uri.parse(path));
  }
}

/// Web-specific app wrapper for optimization
class WebAppWrapper extends StatelessWidget {
  final Widget child;

  const WebAppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!WebConfig.isWeb) return child;

    return Shortcuts(
      shortcuts: WebConfig.getWebKeyboardShortcuts(),
      child: ScrollConfiguration(
        behavior: WebConfig.scrollBehavior,
        child: child,
      ),
    );
  }
}