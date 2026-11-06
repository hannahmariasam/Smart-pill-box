import 'package:flutter/material.dart';

import '../pages/auth_helpers.dart';

/// PillCare design tokens (taken from the Figma design).
class AppColors {
  static const bg = Color(0xFFE7F3FF);
  static const primary = Color(0xFF3478B9);
  static const ink = Color(0xFF193B62);
  static const muted = Color(0xFF526C86);
  static const border = Color(0xFFC9DFF0);
  static const card = Colors.white;

  static const success = Color(0xFF23734F);
  static const successBg = Color(0xFFE3F4EC);
  static const danger = Color(0xFFB63838);
  static const dangerBg = Color(0xFFFDECEC);
  static const warn = Color(0xFF865E08);
  static const warnBg = Color(0xFFFFF4CD);
}

class AppTheme {
  static const String fontFamily = 'Inter';

  static OutlineInputBorder _border(Color c, [double w = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: w),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          surface: AppColors.bg,
          onSurface: AppColors.ink,
          error: AppColors.danger,
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: AppColors.ink,
              displayColor: AppColors.ink,
            ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          hintStyle: const TextStyle(color: AppColors.muted),
          errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
          border: _border(AppColors.border),
          enabledBorder: _border(AppColors.border),
          focusedBorder: _border(AppColors.primary, 1.5),
          errorBorder: _border(AppColors.danger),
          focusedErrorBorder: _border(AppColors.danger, 1.5),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}

// ---------------------------------------------------------------------------
// Formatting helpers
// ---------------------------------------------------------------------------
class Fmt {
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];
  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
    'Sunday',
  ];
  static const _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct',
    'Nov', 'Dec',
  ];

  /// "Thursday, 5 November"
  static String longDate(DateTime d) =>
      '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

  /// "5 Nov 2026"
  static String shortDate(DateTime d) =>
      '${d.day} ${_shortMonths[d.month - 1]} ${d.year}';

  static String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static String firstName(String full) {
    final t = full.trim();
    if (t.isEmpty) return t;
    return t.split(RegExp(r'\s+')).first;
  }

  static String initials(String full) {
    final parts =
        full.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// Tones (status colours)
// ---------------------------------------------------------------------------
enum Tone { info, success, danger, warn }

extension ToneColors on Tone {
  Color get fg {
    switch (this) {
      case Tone.success:
        return AppColors.success;
      case Tone.danger:
        return AppColors.danger;
      case Tone.warn:
        return AppColors.warn;
      case Tone.info:
        return AppColors.primary;
    }
  }

  Color get bg {
    switch (this) {
      case Tone.success:
        return AppColors.successBg;
      case Tone.danger:
        return AppColors.dangerBg;
      case Tone.warn:
        return AppColors.warnBg;
      case Tone.info:
        return AppColors.bg;
    }
  }
}

Tone toneForStatus(String status) {
  switch (status) {
    case 'Taken':
      return Tone.success;
    case 'Missed':
      return Tone.danger;
    default:
      return Tone.info;
  }
}

IconData iconForStatus(String status) {
  switch (status) {
    case 'Taken':
      return Icons.check_circle_outline;
    case 'Missed':
      return Icons.error_outline;
    default:
      return Icons.schedule;
  }
}

// ---------------------------------------------------------------------------
// Page scaffold + heading
// ---------------------------------------------------------------------------

/// Standard PillCare page: tinted background, heading block and a spaced
/// list of children. Main pages show the hamburger menu; sub pages show a
/// back arrow ([showBack]).
class PageScaffold extends StatelessWidget {
  final String overline;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showBack;
  final List<Widget> children;

  const PageScaffold({
    super.key,
    required this.overline,
    required this.title,
    required this.children,
    this.subtitle,
    this.trailing,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      _PageHeading(
        overline: overline,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        showBack: showBack,
      ),
      const SizedBox(height: 22),
    ];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) items.add(const SizedBox(height: 18));
      items.add(children[i]);
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: items,
        ),
      ),
    );
  }
}

class _PageHeading extends StatelessWidget {
  final String overline;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showBack;

  const _PageHeading({
    required this.overline,
    required this.title,
    required this.showBack,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (showBack)
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.maybePop(context),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.arrow_back,
                      size: 24, color: AppColors.primary),
                ),
              )
            else
              const MenuButton(),
            if (showBack || !Session.isFamily) const SizedBox(width: 10),
            Expanded(
              child: Text(
                overline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            height: 1.25,
            color: AppColors.ink,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.muted,
            ),
          ),
        ],
      ],
    );
  }
}

/// Small icon button used in the page heading (bell, search, ...).
class HeadingAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const HeadingAction({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: Icon(icon, size: 23, color: AppColors.primary),
    );
  }
}

// ---------------------------------------------------------------------------
// Building blocks
// ---------------------------------------------------------------------------
class AppCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeading(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
        if (action != null)
          InkWell(
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                action!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Tone tone;
  final IconData? icon;

  const StatusChip(this.label, {super.key, this.tone = Tone.info, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: tone.fg),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: tone.fg,
            ),
          ),
        ],
      ),
    );
  }
}

class NoticeBox extends StatelessWidget {
  final Tone tone;
  final IconData icon;
  final String title;
  final String message;
  final bool white;
  final VoidCallback? onTap;

  const NoticeBox({
    super.key,
    required this.tone,
    required this.icon,
    required this.title,
    required this.message,
    this.white = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: white ? Colors.white : tone.bg,
      radius: 12,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: tone.fg),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: tone.fg,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum AppButtonStyle { primary, outline, danger }

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonStyle style;

  const AppButton(
    this.label, {
    super.key,
    this.icon,
    this.onPressed,
    this.style = AppButtonStyle.primary,
  });

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    BorderSide? side;
    switch (style) {
      case AppButtonStyle.primary:
        bg = AppColors.primary;
        fg = Colors.white;
        break;
      case AppButtonStyle.outline:
        bg = Colors.white;
        fg = AppColors.primary;
        side = const BorderSide(color: AppColors.border);
        break;
      case AppButtonStyle.danger:
        bg = AppColors.dangerBg;
        fg = AppColors.danger;
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: side ?? BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// White pill-shaped segmented control (filters / role selector).
class SegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            i == selected ? Colors.white : AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Label above an input, as in the Figma forms.
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      );
}

class LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final Widget? suffix;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? helper;

  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.suffix,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 16, color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix ??
                (icon == null
                    ? null
                    : Icon(icon, size: 20, color: AppColors.muted)),
          ),
        ),
        if (helper != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              helper!,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
      ],
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  const DetailRow(this.label, this.value,
      {super.key, this.icon, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

/// Count tile (Taken / Missed / Pending).
class CountCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Tone tone;

  const CountCard({
    super.key,
    required this.icon,
    required this.count,
    required this.label,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: tone.fg),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: tone.fg)),
        ],
      ),
    );
  }
}

class CountRow extends StatelessWidget {
  final int taken;
  final int missed;
  final int pending;

  const CountRow({
    super.key,
    required this.taken,
    required this.missed,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CountCard(
            icon: Icons.check_circle_outline,
            count: taken,
            label: 'Taken',
            tone: Tone.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CountCard(
            icon: Icons.error_outline,
            count: missed,
            label: 'Missed',
            tone: Tone.danger,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CountCard(
            icon: Icons.schedule,
            count: pending,
            label: 'Pending',
            tone: Tone.info,
          ),
        ),
      ],
    );
  }
}

/// Rounded tinted tile holding an icon or text.
class IconTile extends StatelessWidget {
  final IconData? icon;
  final String? text;
  final Tone tone;
  final double size;
  final double radius;

  const IconTile({
    super.key,
    this.icon,
    this.text,
    this.tone = Tone.info,
    this.size = 40,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: icon != null
          ? Icon(icon, size: size * 0.5, color: tone.fg)
          : Text(
              text ?? '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: tone.fg,
              ),
            ),
    );
  }
}

/// Confirm dialog used for destructive actions.
Future<bool> confirmDelete(BuildContext context, String name) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Delete medicine?',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink)),
      content: Text('Are you sure you want to delete $name?',
          style: const TextStyle(color: AppColors.muted)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete',
              style: TextStyle(color: AppColors.danger)),
        ),
      ],
    ),
  );
  return ok == true;
}
