import 'package:flutter/material.dart';

/// Shown when a change is on screen but never reached disk.
///
/// A notice is worth showing only when the clinician can do something about it.
/// A change that reached local storage is queued and retried — nothing to act
/// on, nothing shown. A change whose local write threw was never queued, so no
/// retry exists anywhere in the system and the record will quietly not be
/// there tomorrow. That one needs a person.
///
/// Collapses to nothing in the ordinary case, which is almost always.
class WriteFailureBanner extends StatelessWidget {
  const WriteFailureBanner({
    super.key,
    required this.failureLabels,
    required this.onRetryAll,
    required this.onDismiss,
  });

  /// One label per change that was not saved, e.g. "Payment of 1500.00".
  final List<String> failureLabels;

  /// Retry every failed change.
  final VoidCallback onRetryAll;

  /// Hide the notice (the failed changes stay failed).
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    if (failureLabels.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final count = failureLabels.length;
    final what = count == 1
        ? '${failureLabels.first} was not saved'
        : '$count changes were not saved';

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(
            0xFFEF4444,
          ).withValues(alpha: isDark ? 0.16 : 0.09),
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFEF4444).withValues(alpha: 0.45),
              width: 1.2,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 17,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                '$what — this device could not write to storage. '
                'Retry, or note the details before closing the app.',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF7F1D1D),
                ),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: onRetryAll,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
              child: Text(
                count == 1 ? 'Retry' : 'Retry all',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Dismiss',
              onPressed: onDismiss,
              icon: Icon(
                Icons.close_rounded,
                size: 15,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
