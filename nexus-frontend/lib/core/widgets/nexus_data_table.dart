import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'loading_indicator.dart';

class NexusColumn {
  final String label;
  final double? width;
  final int flex;
  final Alignment alignment;

  const NexusColumn({
    required this.label,
    this.width,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
  });
}

class NexusDataTable<T> extends StatelessWidget {
  final List<NexusColumn> columns;
  final List<T> items;
  final List<Widget> Function(BuildContext context, T item, int index) cellBuilder;
  final Widget Function(BuildContext context, T item, int index)? mobileCardBuilder;
  final void Function(T item)? onRowTap;
  final Widget? emptyWidget;
  final bool isLoading;

  const NexusDataTable({
    super.key,
    required this.columns,
    required this.items,
    required this.cellBuilder,
    this.mobileCardBuilder,
    this.onRowTap,
    this.emptyWidget,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    if (isLoading) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const LoadingIndicator(message: 'Loading records...'),
      );
    }

    if (items.isEmpty) {
      return emptyWidget ??
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            alignment: Alignment.center,
            child: Text('No records found.', style: AppTypography.bodyMedium(isDark)),
          );
    }

    if (isMobile && mobileCardBuilder != null) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => mobileCardBuilder!(context, items[index], index),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Column(
          children: [
            // Table Header Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                border: Border(
                  bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              child: Row(
                children: columns.map((col) {
                  final headerText = Text(
                    col.label.toUpperCase(),
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  );

                  if (col.width != null) {
                    return SizedBox(
                      width: col.width,
                      child: Align(alignment: col.alignment, child: headerText),
                    );
                  }
                  return Expanded(
                    flex: col.flex,
                    child: Align(alignment: col.alignment, child: headerText),
                  );
                }).toList(),
              ),
            ),

            // Table Data Rows
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.lightBorder.withValues(alpha: 0.6),
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                final cells = cellBuilder(context, item, index);

                return _DataTableRow(
                  isDark: isDark,
                  onTap: onRowTap != null ? () => onRowTap!(item) : null,
                  children: List.generate(columns.length, (colIdx) {
                    final col = columns[colIdx];
                    final cellWidget = colIdx < cells.length ? cells[colIdx] : const SizedBox();

                    if (col.width != null) {
                      return SizedBox(
                        width: col.width,
                        child: Align(alignment: col.alignment, child: cellWidget),
                      );
                    }
                    return Expanded(
                      flex: col.flex,
                      child: Align(alignment: col.alignment, child: cellWidget),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DataTableRow extends StatefulWidget {
  final bool isDark;
  final VoidCallback? onTap;
  final List<Widget> children;

  const _DataTableRow({
    required this.isDark,
    required this.children,
    this.onTap,
  });

  @override
  State<_DataTableRow> createState() => _DataTableRowState();
}

class _DataTableRowState extends State<_DataTableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
          color: _isHovered
              ? (widget.isDark ? AppColors.darkSurfaceElevated.withValues(alpha: 0.8) : AppColors.lightSurfaceElevated)
              : Colors.transparent,
          child: Row(children: widget.children),
        ),
      ),
    );
  }
}
