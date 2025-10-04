import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../theme/app_theme.dart';

/// Main layout wrapper that provides responsive structure
class ResponsiveLayout extends StatelessWidget {
  final Widget body;
  final Widget? sidebar;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final bool showSidebar;

  const ResponsiveLayout({
    super.key,
    required this.body,
    this.sidebar,
    this.appBar,
    this.floatingActionButton,
    this.showSidebar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: ResponsiveBuilder(
        mobile: body,
        tablet: body,
        desktop: showSidebar && sidebar != null
            ? _buildDesktopLayoutWithSidebar(context)
            : _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return ResponsiveContainer(
      child: body,
    );
  }

  Widget _buildDesktopLayoutWithSidebar(BuildContext context) {
    return Row(
      children: [
        // Sidebar
        Container(
          width: Responsive.getSidebarWidth(context),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            border: Border(
              right: BorderSide(
                color: AppTheme.textSecondaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: sidebar!,
        ),
        // Main content
        Expanded(
          child: ResponsiveContainer(
            child: body,
          ),
        ),
      ],
    );
  }
}

/// Responsive card that adjusts its layout based on screen size
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? Responsive.getCardWidth(context),
      height: height,
      margin: margin ?? EdgeInsets.all(Responsive.getSpacing(context) / 2),
      child: Card(
        elevation: Responsive.responsive(
          context,
          mobile: 2,
          tablet: 3,
          desktop: 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            Responsive.responsive(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.all(Responsive.getSpacing(context)),
          child: child,
        ),
      ),
    );
  }
}

/// Responsive grid that adjusts columns based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? childAspectRatio;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.getGridColumns(context);
    final spacing = Responsive.getSpacing(context);

    return GridView.count(
      crossAxisCount: columns,
      childAspectRatio: childAspectRatio ?? 1.5,
      mainAxisSpacing: mainAxisSpacing ?? spacing,
      crossAxisSpacing: crossAxisSpacing ?? spacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

/// Responsive list that switches between list and grid based on screen size
class ResponsiveListGrid extends StatelessWidget {
  final List<Widget> children;
  final bool forceList;

  const ResponsiveListGrid({
    super.key,
    required this.children,
    this.forceList = false,
  });

  @override
  Widget build(BuildContext context) {
    if (forceList || Responsive.isMobile(context)) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      );
    } else {
      return ResponsiveGrid(children: children);
    }
  }
}