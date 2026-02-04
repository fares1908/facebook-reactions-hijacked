import 'package:flutter/material.dart';
import 'package:flutter_animated_reaction/reaction.dart';

class ReactionOverlay extends StatefulWidget {
  const ReactionOverlay({
    super.key,
    required this.onDismiss,
    required this.onPressReact,
    required this.relativeRect,
    required this.overlaySize,
    required this.reactions,
    this.backgroundColor,
    this.size,
  });

  final VoidCallback onDismiss;
  final Function(int) onPressReact;
  final List<String> reactions;
  final RelativeRect relativeRect;
  final double overlaySize;
  final Color? backgroundColor;
  final Size? size;

  @override
  State<ReactionOverlay> createState() => _ReactionOverlayState();
}

class _ReactionOverlayState extends State<ReactionOverlay>
    with TickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInSine,
    );

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use real screen size (not affected by SafeArea builder)
    final mq = MediaQueryData.fromView(View.of(context));

    return SizedBox(
      width: mq.size.width,
      height: mq.size.height,
      child: Stack(
        fit: StackFit.expand, // ensure the coordinate space matches screen
        children: [
          ModalBarrier(onDismiss: widget.onDismiss),
          Positioned.fromRelativeRect(
            rect: widget.relativeRect,
            child: ScaleTransition(
              scale: animation,
              child: Material(
                type: MaterialType.card,
                elevation: 0.5,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: widget.overlaySize,
                  constraints:
                      const BoxConstraints(maxHeight: 60, minHeight: 60),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: widget.backgroundColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 0; i < widget.reactions.length; i++)
                        Reaction(
                          path: widget.reactions[i],
                          onTap: widget.onPressReact,
                          index: i,
                          size: widget.size ?? const Size(45, 45),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
