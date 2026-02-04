library flutter_animated_reaction;

import 'package:flutter/material.dart';
import 'package:flutter_animated_reaction/reaction_data.dart';
import 'package:flutter_animated_reaction/reaction_overlay.dart';

class AnimatedFlutterReaction {
  OverlayEntry? overlayEntry;
  late OverlayState overlayState;

  void showOverlay({
    required BuildContext context,
    required GlobalKey key,
    List<String>? reactions,
    required Function(int) onReaction,
    Color? backgroundColor,
    double? overlaySize,
    Size? iconSize,
  }) {
    // Use the real screen metrics (not affected by SafeArea builder)
    final mq = MediaQueryData.fromView(View.of(context));
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final padTop = mq.viewPadding.top;
    final padBottom = mq.viewPadding.bottom;

    final box = key.currentContext!.findRenderObject() as RenderBox;
    final topLeft = box.size.topCenter(box.localToGlobal(Offset.zero));
    final bottomRight = box.size.bottomCenter(box.localToGlobal(Offset.zero));

    overlaySize ??= screenW * 0.9;

    const barH = 60.0; // must match ReactionOverlay bar constraints
    const gap = 10.0;
    const margin = 8.0;

    final placeAbove = topLeft.dy > screenH * 0.3;

    double top =
        placeAbove ? (topLeft.dy - barH - gap) : (bottomRight.dy + gap);

    // Keep bar inside system safe areas
    final minTop = padTop + margin;
    final maxTop = screenH - padBottom - barH - margin;
    top = top.clamp(minTop, maxTop);

    final left = (screenW - overlaySize!) / 2;
    final right = left;
    final bottom = screenH - top - barH;

    final relativeRect = RelativeRect.fromLTRB(left, top, right, bottom);

    overlayEntry = OverlayEntry(
      builder: (_) => ReactionOverlay(
        onDismiss: () => hideOverlay(),
        relativeRect: relativeRect,
        overlaySize: overlaySize!,
        reactions: reactions ?? ReactionData.facebookReactionIcon,
        onPressReact: (val) {
          hideOverlay();
          onReaction(val);
        },
        size: iconSize,
        backgroundColor: backgroundColor ?? Colors.white,
      ),
    );

    // IMPORTANT: insert into ROOT overlay (not the one wrapped by SafeArea builder)
    overlayState = Overlay.of(context, rootOverlay: true);
    overlayState.insert(overlayEntry!);
  }

  void hideOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }
}
