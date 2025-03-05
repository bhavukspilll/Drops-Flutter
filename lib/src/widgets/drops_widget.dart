import 'package:flutter/cupertino.dart';

import '../utils/drop_position.dart';
import '../utils/drop_shape.dart';

class Drops {
  static void show(
    BuildContext context, {
    required String title,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    Duration? transitionDuration = const Duration(milliseconds: 700),
    TextStyle? textStyle,
    Curve curve = Curves.easeOutExpo,
    Curve? reverseCurve,
    String? subtitle,
    IconData? icon,
    bool? isDestructive,
    TextStyle? titleTextStyle,
    TextStyle? subtitleTextStyle,
    DropPosition? position = DropPosition.top,
    EdgeInsets? padding,
    DropShape? shape,
    bool? highContrastText,
  }) {
    OverlayEntry? currentOverlay;
    currentOverlay = OverlayEntry(
      builder:
          (context) => _DropsWidget(
            title: title,
            backgroundColor: backgroundColor,
            duration: duration,
            transitionDuration: transitionDuration,
            curve: curve,
            reverseCurve: reverseCurve,
            isDestructive: isDestructive ?? false,
            subtitle: subtitle,
            titleTextStyle: titleTextStyle,
            subtitleTextStyle: subtitleTextStyle,
            position: position,
            padding: padding,
            shape: shape,
            highContrastText: highContrastText ?? true,
            icon: icon,
            onDismiss: () {
              currentOverlay?.remove();

              currentOverlay = null;
            },
          ),
    );
    Overlay.of(context).insert(currentOverlay!);
  }
}

class _DropsWidget extends StatefulWidget {
  final String title;
  final Color? backgroundColor;
  final Duration duration;
  final Duration? transitionDuration;
  final Curve curve;
  final Curve? reverseCurve;
  final VoidCallback onDismiss;
  final IconData? icon;
  final String? subtitle;
  final bool isDestructive;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final DropPosition? position;
  final EdgeInsets? padding;
  final DropShape? shape;
  final bool highContrastText;

  const _DropsWidget({
    required this.title,
    this.backgroundColor,
    required this.duration,

    this.curve = Curves.fastEaseInToSlowEaseOut,
    this.reverseCurve,
    required this.onDismiss,
    this.icon,
    this.subtitle,
    this.transitionDuration,
    this.isDestructive = false,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.position,
    this.padding,
    this.shape = DropShape.pill,
    this.highContrastText = true,
  });

  @override
  _DropsWidgetState createState() => _DropsWidgetState();
}

class _DropsWidgetState extends State<_DropsWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(duration: widget.transitionDuration, vsync: this);

    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, widget.position == DropPosition.top ? -1 : 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
        reverseCurve: widget.reverseCurve ?? widget.curve.flipped,
      ),
    );

    _animationController.forward();

    Future.delayed(widget.duration, () {
      if (mounted) _dismissAlert();
    });

    _scrollController.addListener(() {
      if (_scrollController.offset > 30 && widget.position == DropPosition.top) {
        _dismissAlert();
      }

      if (_scrollController.offset < -30 && widget.position == DropPosition.bottom) {
        _dismissAlert();
      }
    });
  }

  void _dismissAlert() {
    _animationController.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: widget.position == DropPosition.top ? 0 : null,
      bottom: widget.position == DropPosition.bottom ? 0 + MediaQuery.of(context).viewPadding.bottom : null,
      right: 0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          controller: _scrollController,
          hitTestBehavior: HitTestBehavior.deferToChild,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: SafeArea(
            child: Center(
              child: Container(
                clipBehavior: widget.shape == DropShape.squared ? Clip.none : Clip.antiAlias,
                decoration: ShapeDecoration(
                  shape: StadiumBorder(),
                  shadows: [
                    BoxShadow(
                      color: CupertinoColors.black.withAlpha(30),
                      blurRadius: 40,
                      spreadRadius: 20,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: CupertinoPopupSurface(
                  child: Padding(
                    padding:
                        widget.padding ??
                        EdgeInsets.only(
                          left: widget.subtitle != null && widget.icon == null ? 30 : 20,
                          right:
                              widget.icon != null
                                  ? 28
                                  : widget.subtitle != null
                                  ? 30
                                  : 20,
                          top: widget.subtitle != null ? 10 : 16,
                          bottom: widget.subtitle != null ? 10 : 16,
                        ),
                    child: Row(
                      spacing: 11,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.icon != null)
                          Icon(
                            widget.icon,
                            color:
                                widget.isDestructive
                                    ? CupertinoColors.destructiveRed.resolveFrom(context)
                                    : CupertinoColors.secondaryLabel.resolveFrom(context),
                          ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.title,
                              style:
                                  widget.titleTextStyle ??
                                  TextStyle(
                                    color:
                                        widget.highContrastText
                                            ? CupertinoColors.label.resolveFrom(context)
                                            : CupertinoColors.secondaryLabel.resolveFrom(context),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            if (widget.subtitle != null)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.subtitle!,
                                    style:
                                        widget.subtitleTextStyle ??
                                        TextStyle(
                                          color:
                                              widget.highContrastText
                                                  ? CupertinoColors.secondaryLabel.resolveFrom(context)
                                                  : CupertinoColors.tertiaryLabel.resolveFrom(context),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


