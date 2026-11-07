import 'dart:convert';

import 'package:flutter/material.dart';

/// A unified, highly resilient avatar widget for all users across iDentist Live.
///
/// Features:
/// 1. Supports HTTPS/HTTP image URLs.
/// 2. Supports Data URIs (`data:image/...;base64,...`) and raw base64 strings.
/// 3. Offline & Cold Boot Resilience: If [photo] is empty, uses [fallbackPhoto]
///    (for example a cached copy the session keeps) when
///    [enableLocalCacheFallback] is true.
/// 4. Graceful Fallback: When photo is missing or fails to render, renders initials
///    or [fallbackIcon] with a vibrant tint instead of a broken/empty circle.
/// 5. Self-Healing Memory Cache: Evicts failed image providers upon error so retries succeed.
/// 6. RepaintBoundary isolation for zero parent repaint overhead.
class UserAvatar extends StatefulWidget {
  final String? photo;
  final String displayName;
  final double radius;
  final Color? primaryColor;
  final IconData? fallbackIcon;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final bool enableLocalCacheFallback;

  /// Shown when [photo] is empty and [enableLocalCacheFallback] is true.
  final String? fallbackPhoto;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.photo,
    required this.displayName,
    this.radius = 20,
    this.primaryColor,
    this.fallbackIcon,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 1.5,
    this.enableLocalCacheFallback = true,
    this.fallbackPhoto,
    this.onTap,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  static final Map<String, ImageProvider> _providerCache = {};

  ImageProvider? _imageProvider;
  String _resolvedSource = '';

  @override
  void initState() {
    super.initState();
    _resolveProvider();
  }

  @override
  void didUpdateWidget(covariant UserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPhoto = oldWidget.photo?.trim() ?? '';
    final newPhoto = widget.photo?.trim() ?? '';
    if (oldPhoto != newPhoto ||
        oldWidget.fallbackPhoto != widget.fallbackPhoto ||
        oldWidget.enableLocalCacheFallback != widget.enableLocalCacheFallback ||
        oldWidget.displayName != widget.displayName ||
        oldWidget.radius != widget.radius) {
      setState(() {
        _resolveProvider();
      });
    }
  }

  void _resolveProvider() {
    String source = widget.photo?.trim() ?? '';

    if (source.isEmpty && widget.enableLocalCacheFallback) {
      source = widget.fallbackPhoto?.trim() ?? '';
    }

    _resolvedSource = source;

    if (source.isEmpty) {
      _imageProvider = null;
      return;
    }

    if (_providerCache.containsKey(source)) {
      _imageProvider = _providerCache[source];
      return;
    }

    ImageProvider? provider;
    if (source.startsWith('http://') || source.startsWith('https://')) {
      provider = NetworkImage(source);
    } else {
      provider = _memoryImageFrom(source);
    }

    if (provider != null) {
      if (_providerCache.length > 60) _providerCache.clear();
      _providerCache[source] = provider;
    }

    _imageProvider = provider;
  }

  /// Decodes a data URI (`data:image/...;base64,...`) or a raw base64 string
  /// (standard or URL-safe, padding optional). Null when it is not base64.
  static MemoryImage? _memoryImageFrom(String source) {
    var data = source.trim();
    final comma = data.indexOf(',');
    if (data.startsWith('data:') && comma != -1) {
      data = data.substring(comma + 1);
    }
    data = data.replaceAll(RegExp(r'\s'), '');
    if (data.isEmpty) return null;
    try {
      final bytes = base64.decode(base64.normalize(data));
      return bytes.isEmpty ? null : MemoryImage(bytes);
    } on FormatException {
      return null;
    }
  }

  void _handleImageError() {
    if (_resolvedSource.isNotEmpty) {
      _providerCache.remove(_resolvedSource);
      _imageProvider?.evict();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double diameter = widget.radius * 2;
    final Color accent = widget.primaryColor ?? Theme.of(context).primaryColor;

    Widget avatarContent = RepaintBoundary(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: ClipOval(
          child: Container(
            width: diameter,
            height: diameter,
            color: accent.withValues(alpha: 0.12),
            child: _imageProvider != null
                ? Image(
                    key: ValueKey(_imageProvider),
                    image: _imageProvider!,
                    width: diameter,
                    height: diameter,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (context, error, stackTrace) {
                      _handleImageError();
                      return _buildFallback(accent);
                    },
                  )
                : _buildFallback(accent),
          ),
        ),
      ),
    );

    if (widget.showBorder) {
      avatarContent = Container(
        width: diameter + (widget.borderWidth * 2),
        height: diameter + (widget.borderWidth * 2),
        padding: EdgeInsets.all(widget.borderWidth),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.borderColor ?? accent.withValues(alpha: 0.5),
            width: widget.borderWidth,
          ),
        ),
        child: avatarContent,
      );
    }

    if (widget.onTap != null) {
      return InkWell(
        onTap: widget.onTap,
        customBorder: const CircleBorder(),
        child: avatarContent,
      );
    }

    return avatarContent;
  }

  Widget _buildFallback(Color accent) {
    if (widget.fallbackIcon != null) {
      return Center(
        child: Icon(
          widget.fallbackIcon,
          size: widget.radius * 0.95,
          color: accent,
        ),
      );
    }

    final trimmedName = widget.displayName.trim();
    final initial = trimmedName.isNotEmpty ? trimmedName[0].toUpperCase() : 'U';

    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: widget.radius * 0.78,
          color: accent,
        ),
      ),
    );
  }
}

/// Backward compatibility alias for legacy references.
typedef SkeletonUserAvatar = UserAvatar;
