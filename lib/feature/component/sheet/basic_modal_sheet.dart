import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';

class BasicModalSheet extends StatelessWidget {
  const BasicModalSheet({
    super.key,
    required this.controller,
    required this.children,
  });
  final SheetController controller;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Sheet(
      backgroundColor: Colors.transparent,
      initialExtent: 120,
      controller: controller,
      physics: const SnapSheetPhysics(
        stops: <double>[0.1, 0.3, 1],
      ),
      /*   snap: true,
                stops: [0, 0.1, 0.3, 0.5, 1], */
      child: AnimatedBuilder(
        animation: controller.animation,
        builder: (BuildContext context, Widget? child) {
          final sheetBar = controller.animation.value > 0.95;
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: sheetBar ? 1 : 0),
            duration: const Duration(milliseconds: 200),
            builder: (BuildContext context, double t, Widget? child) {
              final radius = Tween<double>(begin: 16, end: 0).transform(t);

              final shadow = ColorTween(
                begin: Colors.black26,
                end: Colors.black26.withOpacity(0),
              ).transform(t);
              final barColor = ColorTween(
                begin: Colors.grey[200],
                end: Colors.grey[200]?.withOpacity(0),
              ).transform(t);
              return MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(radius),
                      topRight: Radius.circular(radius),
                    ),
                    color: theme.colorScheme.surface,
                    boxShadow: <BoxShadow>[
                      BoxShadow(color: shadow!, blurRadius: 12),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        width: 36,
                        height: 4,
                        color: barColor,
                        alignment: Alignment.center,
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(8),
                          children: children,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
