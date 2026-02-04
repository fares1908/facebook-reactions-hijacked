// animated_flutter_reaction.dart
library flutter_animated_reaction;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animated_reaction/reaction_data.dart';
import 'package:flutter_animated_reaction/reaction_overlay.dart';

class AnimatedFlutterReaction {
  OverlayEntry? overlayEntry;
  OverlayState? overlayState;

  void showOverlay({
    required BuildContext context,
    required GlobalKey key,
    List<String>? reactions,
    required Function(int) onReaction,
    Color? backgroundColor,
    double? overlaySize,
    Size? iconSize,
  }) {
    hideOverlay();

    final targetCtx = key.currentContext;
    if (targetCtx == null) return;

    // ✅ IMPORTANT: use overlay INSIDE the widget tree (affected by SafeArea)
    final overlay = Overlay.of(context); // <-- no rootOverlay
    overlayState = overlay;

    final overlayRO = overlay.context.findRenderObject();
    if (overlayRO is! RenderBox || !overlayRO.hasSize) return;
    final overlayBox = overlayRO;

    final targetRO = targetCtx.findRenderObject();
    if (targetRO is! RenderBox || !targetRO.hasSize) return;
    final render = targetRO;

    // ✅ Real available space for overlay (after SafeArea)
    final screenW = overlayBox.size.width;
    final screenH = overlayBox.size.height;

    // ✅ Insets: top must still respect status bar even if SafeArea(top:false)
    final mq = MediaQuery.of(context);
    final padTop = mq.viewPadding.top;

    // ✅ bottom: take the biggest (safe padding / nav bar / gesture area)
    final padBottom = math.max(
      math.max(mq.padding.bottom, mq.viewPadding.bottom),
      mq.systemGestureInsets.bottom,
    );

    // ✅ Position relative to overlay (same coordinate space!)
    final pos = render.localToGlobal(Offset.zero, ancestor: overlayBox);
    final topCenter = render.size.topCenter(pos);
    final bottomCenter = render.size.bottomCenter(pos);

    overlaySize ??= screenW * 0.9;

    const barH = 60.0;
    const gap = 10.0;
    const margin = 8.0;

    final placeAbove = topCenter.dy > screenH * 0.3;

    double top =
        placeAbove ? (topCenter.dy - barH - gap) : (bottomCenter.dy + gap);

    // Keep bar inside safe bounds
    final minTop = padTop + margin;
    final maxTop = screenH - padBottom - barH - margin;
    top = top.clamp(minTop, maxTop);

    final left = (screenW - overlaySize!) / 2;
    final bottom = screenH - top - barH;

    final relativeRect = RelativeRect.fromLTRB(left, top, left, bottom);

    overlayEntry = OverlayEntry(
      builder: (_) => ReactionOverlay(
        onDismiss: hideOverlay,
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

    overlayState!.insert(overlayEntry!);
  }

  void hideOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }
}
