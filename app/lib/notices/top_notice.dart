import 'dart:async';
import 'package:flutter/material.dart';
import 'package:identist_app/panels/popup_look.dart';

/// Top-right corner compact notification helper with snappy instant auto-hide.
class TopNotification {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    Color? color,
    IconData? icon,
    Duration duration = const Duration(milliseconds: 1700),
    OverlayState? overlayState,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final targetOverlay =
        overlayState ??
        Overlay.maybeOf(context, rootOverlay: true) ??
        Overlay.maybeOf(context);
    if (targetOverlay == null) return;

    try {
      if (_currentEntry != null && _currentEntry!.mounted) {
        _currentEntry!.remove();
      }
    } catch (_) {}
    _currentEntry = null;

    late OverlayEntry overlayEntry;

    final effectiveContext = overlayState != null
        ? targetOverlay.context
        : context;
    final theme = Theme.of(effectiveContext);
    final look = UiPopupScope.maybeOf(context);
    final isDark = look?.dark ?? theme.brightness == Brightness.dark;
    final baseColor =
        color ?? (isError ? const Color(0xFFEF4444) : const Color(0xFF10B981));

    overlayEntry = OverlayEntry(
      builder: (context) {
        return _TopNotificationWidget(
          message: message,
          isError: isError,
          baseColor: baseColor,
          icon: icon,
          isDark: isDark,
          look: look,
          duration: duration,
          actionLabel: actionLabel,
          onAction: onAction,
          onDismiss: () {
            try {
              if (overlayEntry.mounted) {
                overlayEntry.remove();
              }
              if (_currentEntry == overlayEntry) {
                _currentEntry = null;
              }
            } catch (_) {}
          },
        );
      },
    );

    _currentEntry = overlayEntry;
    targetOverlay.insert(overlayEntry);
  }

  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1700),
  }) => show(context, message: message, isError: false, duration: duration);

  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2100),
  }) => show(context, message: message, isError: true, duration: duration);

  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1700),
  }) => show(
    context,
    message: message,
    isError: false,
    color: const Color(0xFF0284C7),
    duration: duration,
  );
}

typedef AppNotification = TopNotification;

class _TopNotificationWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final Color baseColor;
  final IconData? icon;
  final bool isDark;
  final UiPopupLook? look;

  /// [Duration.zero]: stays until dismissed or acted on (for example
  /// "Update ready · Reload now").
  final Duration duration;
  final VoidCallback onDismiss;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _TopNotificationWidget({
    required this.message,
    required this.isError,
    required this.baseColor,
    this.icon,
    required this.isDark,
    this.look,
    required this.duration,
    required this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<_TopNotificationWidget> createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<_TopNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 150),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.35, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    if (widget.duration > Duration.zero) {
      _dismissTimer = Timer(widget.duration, () async {
        if (mounted) {
          await _controller.reverse();
          widget.onDismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Positioned(
      top: mediaQuery.padding.top + 14,
      right: 14,
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Semantics(
              liveRegion: true,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: mediaQuery.size.width < 380
                      ? mediaQuery.size.width - 28
                      : 285,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color:
                      widget.look?.surface.withValues(alpha: 0.98) ??
                      (widget.isDark
                          ? const Color(0xFF1E293B).withValues(alpha: 0.96)
                          : Colors.white.withValues(alpha: 0.98)),
                  borderRadius: BorderRadius.circular(
                    widget.look == null ? 10 : 14,
                  ),
                  border: Border.all(
                    color: widget.baseColor.withValues(alpha: 0.4),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.baseColor.withValues(alpha: 0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: widget.isDark ? 0.35 : 0.07,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: widget.baseColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon ??
                            (widget.isError
                                ? Icons.error_outline_rounded
                                : Icons.check_circle_rounded),
                        color: widget.baseColor,
                        size: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.message,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color:
                                  widget.look?.text ??
                                  (widget.isDark
                                      ? Colors.white
                                      : Colors.black87),
                              letterSpacing: -0.1,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.actionLabel != null &&
                              widget.onAction != null) ...[
                            const SizedBox(height: 6),
                            Semantics(
                              button: true,
                              child: GestureDetector(
                                key: const Key('top_notification_action'),
                                behavior: HitTestBehavior.opaque,
                                onTap: () async {
                                  _dismissTimer?.cancel();
                                  widget.onAction!();
                                  if (mounted) {
                                    await _controller.reverse();
                                    widget.onDismiss();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.baseColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.actionLabel!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Semantics(
                      button: true,
                      label: 'Dismiss',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          _dismissTimer?.cancel();
                          if (mounted) {
                            await _controller.reverse();
                            widget.onDismiss();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.close_rounded,
                            size: 13,
                            color:
                                widget.look?.faint ??
                                (widget.isDark
                                    ? Colors.white38
                                    : Colors.black38),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
