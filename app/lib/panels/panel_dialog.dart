import 'package:flutter/material.dart';
import 'package:identist_app/panels/popup_look.dart';

/// A detail panel as a dialog — used in place of `showModalBottomSheet`.
///
/// Same look as the dialog pattern (`showAddProcedureDialog`): a solid,
/// theme-matched surface, 20 px radius, a subtle border, width-limited on a
/// desktop and near full width on a phone. The content is whatever the sheet
/// used to show; this only changes how it is presented.
///
/// A panel that owns text controllers still opens through `showFormDialog`.
Future<T?> showPanelDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double maxWidth = 620,
}) {
  return showGlassDialog<T>(
    context: context,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final size = MediaQuery.sizeOf(ctx);
      final look = UiPopupScope.maybeOf(ctx);
      return UiDialog(
        backgroundColor: uiPopupSurface(
          ctx,
          isDark ? const Color(0xFF0B1329) : Colors.white,
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: size.width <= 900 ? 12 : 40,
          vertical: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(look == null ? 20 : 24),
          side: BorderSide(
            color:
                look?.edge ??
                (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: size.height * 0.9,
          ),
          child: builder(ctx),
        ),
      );
    },
  );
}

/// Supplies a scroll controller to panel content that was written for a
/// `DraggableScrollableSheet`, and disposes it with the panel.
class ScrollablePanel extends StatefulWidget {
  const ScrollablePanel({super.key, required this.builder});

  final Widget Function(BuildContext context, ScrollController controller)
  builder;

  @override
  State<ScrollablePanel> createState() => _ScrollablePanelState();
}

class _ScrollablePanelState extends State<ScrollablePanel> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}
