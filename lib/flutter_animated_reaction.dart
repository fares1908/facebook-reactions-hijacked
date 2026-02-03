library flutter_animated_reaction;

import 'package:flutter/material.dart';
import 'package:flutter_animated_reaction/reaction_data.dart';
import 'package:flutter_animated_reaction/reaction_overlay.dart';

class AnimatedFlutterReaction {
  late final OverlayEntry? overlayEntry;
  late OverlayState overlayState;

  void showOverlay({
    required BuildContext context,
    required GlobalKey key,
    List<String>? reactions,
    required Function(int) onReaction,
    Color? backgroundColor,
    double? overlaySize,
    double? overlayHeight,
    Size? iconSize,
  }) {
    final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;

    final Offset topLeft = box.size.topCenter(box.localToGlobal(Offset.zero));
    final Offset bottomRight =
        box.size.bottomCenter(box.localToGlobal(Offset.zero));

    final media = MediaQuery.of(context);
    final screenW = media.size.width;
    final screenH = media.size.height;

    overlaySize ??= screenW * 0.9;

    final double h = overlayHeight ?? 60;

    final double gap = 10;

    double top =
        topLeft.dy > screenH * 0.3 ? topLeft.dy - h - gap : bottomRight.dy;

    double bottom = topLeft.dy < screenH * 0.3
        ? screenH - bottomRight.dy - h
        : screenH - bottomRight.dy + (bottomRight.dy - topLeft.dy) + gap;

    final RelativeRect relativeRect = RelativeRect.fromLTRB(
      (screenW - overlaySize!) / 2,
      top,
      (screenW - overlaySize) / 2,
      bottom,
    );

    overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return ReactionOverlay(
          overlayHeight: h,
          onDismiss: () => hideOverlay(context),
          relativeRect: relativeRect,
          overlaySize: overlaySize ?? screenW * 0.3,
          reactions: reactions ?? ReactionData.facebookReactionIcon,
          onPressReact: (val) {
            hideOverlay(context);
            onReaction(val);
          },
          size: iconSize,
          backgroundColor: backgroundColor ?? Colors.white,
        );
      },
    );

    overlayState = Overlay.of(context);
    overlayState.insert(overlayEntry!);
  }

  void hideOverlay(BuildContext context) {
    overlayEntry?.remove();
  }
}
