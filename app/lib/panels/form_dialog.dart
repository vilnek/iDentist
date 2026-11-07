import 'package:flutter/material.dart';
import 'package:identist_app/panels/popup_look.dart';

/// A dialog that owns its text controllers and wraps its body in a [Form].
///
/// Every dialog on the patient detail screen was built as
/// `showGlassDialog(builder: (context) => StatefulBuilder(builder: (ctx, setState)))`
/// with its controllers created in the enclosing method. That shape has no
/// `dispose` anywhere in it, so all 38 of them leaked their listeners on every
/// open — the profile dialog alone leaked seven per open — and it has nowhere to
/// hang a [FormState], which is why the screen had 18 forms and not one
/// validator.
///
/// [showFormDialog] is a drop-in for that pattern: same `StatefulBuilder`
/// semantics, plus a real `dispose()` and a [GlobalKey] the save handler can
/// call `validate()` on.
Future<T?> showFormDialog<T>({
  required BuildContext context,
  required List<TextEditingController> controllers,
  required Widget Function(
    BuildContext ctx,
    StateSetter setModalState,
    GlobalKey<FormState> formKey,
  )
  builder,
  bool barrierDismissible = true,
  bool Function()? hasUnsavedWork,
}) {
  return showGlassDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) => _FormDialogHost(
      controllers: controllers,
      builder: builder,
      hasUnsavedWork: hasUnsavedWork,
    ),
  );
}

class _FormDialogHost extends StatefulWidget {
  final List<TextEditingController> controllers;
  final Widget Function(BuildContext, StateSetter, GlobalKey<FormState>)
  builder;

  final bool Function()? hasUnsavedWork;

  const _FormDialogHost({
    required this.controllers,
    required this.builder,
    this.hasUnsavedWork,
  });

  @override
  State<_FormDialogHost> createState() => _FormDialogHostState();
}

class _FormDialogHostState extends State<_FormDialogHost> {
  final _formKey = GlobalKey<FormState>();

  /// The text each field opened with, to tell typed changes apart.
  late final List<String> _opened = [
    for (final c in widget.controllers) c.text,
  ];
  bool _asking = false;

  bool get _changed {
    if (widget.hasUnsavedWork?.call() ?? false) return true;
    for (var i = 0; i < widget.controllers.length; i++) {
      if (widget.controllers[i].text != _opened[i]) return true;
    }
    return false;
  }

  /// Bug board #8 (full re-test 2026-10-16): a tap beside the form (often
  /// meant to hide the keyboard) or a back swipe closed it and threw away
  /// everything typed, with no word. Now it asks first. Save and the form's
  /// own close button are unchanged (they close on purpose).
  Future<void> _askBeforeClosing() async {
    if (_asking) return;
    _asking = true;
    FocusManager.instance.primaryFocus?.unfocus();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final discard = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const UiDialogIcon(Icons.edit_note_rounded),
        backgroundColor: uiPopupSurface(
          ctx,
          isDark ? const Color(0xFF0B1329) : Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Discard changes?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('What you typed in this form is not saved yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).primaryColor,
              foregroundColor: Colors.black87,
            ),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
        ],
      ),
    );
    _asking = false;
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    for (final c in widget.controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(widget.controllers),
      builder: (context, child) => PopScope<Object?>(
        canPop: !_changed,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _askBeforeClosing();
        },
        child: child!,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: widget.builder(context, setState, _formKey),
      ),
    );
  }
}

/// Validates the form and returns whether the save may proceed.
///
/// The dialogs used to guard saves with a bare `if (amount <= 0) return;` — the
/// button did nothing, showed nothing, and explained nothing, so the user either
/// pressed it again or assumed it had worked. Routing through the form means the
/// reason lands under the field that caused it.
bool formIsValid(GlobalKey<FormState> key) =>
    key.currentState?.validate() ?? false;

/// Disposes [controllers] once [dialog] closes — however it closes.
///
/// The companion to [showFormDialog], for dialogs that are not forms and so
/// have no `_FormDialogHost` to hang a lifecycle on. They build their own
/// `StatefulBuilder` over a raw `showDialog`, which gives them no `dispose()`
/// at all: the controllers are made in a top-level function before the dialog
/// opens and simply outlive it, once per open, for the life of the session.
///
/// `finally`, not `.then`, so a dismissed dialog and a thrown builder both
/// release. Returns the dialog's own result untouched.
Future<T?> disposingControllers<T>(
  Future<T?> dialog,
  List<TextEditingController> controllers,
) async {
  try {
    return await dialog;
  } finally {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final c in controllers) {
        c.dispose();
      }
    });
  }
}
