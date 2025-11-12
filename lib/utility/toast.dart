import 'dart:async';
import 'package:flutter/material.dart';

enum ToastType { info, success, error }

class Toast {
  static OverlayEntry? _current;
  static Timer? _timer;

  static void show(
      BuildContext context, {
        required String message,
        ToastType type = ToastType.info,
        Duration duration = const Duration(seconds: 2),
      }) {
    _removeCurrent();

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final theme = Theme.of(context);
    final (bg, icon) = _styleFor(type, theme);

    final entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        background: bg,
        icon: icon,
      ),
    );

    overlay.insert(entry);
    _current = entry;

    _timer = Timer(duration, _removeCurrent);
  }

  static void _removeCurrent() {
    _timer?.cancel();
    _timer = null;
    _current?.remove();
    _current = null;
  }

  static (Color, IconData) _styleFor(ToastType type, ThemeData theme) {
    switch (type) {
      case ToastType.success:
        return (Colors.green.shade700, Icons.check_circle_rounded);
      case ToastType.error:
        return (Colors.red.shade700, Icons.error_rounded);
      case ToastType.info:
      default:
        return (theme.colorScheme.inverseSurface, Icons.info_rounded);
    }
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color background;
  final IconData icon;

  const _ToastWidget({
    required this.message,
    required this.background,
    required this.icon,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<Offset> _offset;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _offset = Tween(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom; // per non coprire la keyboard
    return IgnorePointer(
      ignoring: true,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 16,
              right: 16,
              bottom: 16 + bottomInset,
              child: SlideTransition(
                position: _offset,
                child: FadeTransition(
                  opacity: _opacity,
                  child: _ToastCard(
                    background: widget.background,
                    icon: widget.icon,
                    message: widget.message,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  final Color background;
  final IconData icon;
  final String message;

  const _ToastCard({
    required this.background,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
