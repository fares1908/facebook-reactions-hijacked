library flutter_animated_reaction;

import 'package:flutter/material.dart';
import 'package:flutter_animated_reaction/reaction_data.dart';
import 'package:flutter_animated_reaction/reaction_overlay.dart';

class AnimatedFlutterReaction {
  late final OverlayEntry? overlayEntry;
  late OverlayState overlayState;

  void showOverlay(
      {required BuildContext context,
      required GlobalKey key,
      List<String>? reactions,
      required Function(int) onReaction,
      Color? backgroundColor,
      double? overlaySize,
      Size? iconSize}) {
    RenderBox? box = key.currentContext!.findRenderObject() as RenderBox;
    final Offset topLeft = box.size.topCenter(box.localToGlobal(Offset.zero));
    final Offset bottomRight =
        box.size.bottomCenter(box.localToGlobal(Offset.zero));
    overlaySize ??= MediaQuery.of(context).size.width * 0.9;

    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;

    double top = topLeft.dy > MediaQuery.of(context).size.height * 0.3
        ? topLeft.dy - 70
        : bottomRight.dy;
    double bottom = topLeft.dy < MediaQuery.of(context).size.height * 0.3
        ? MediaQuery.of(context).size.height - bottomRight.dy - 60
        : MediaQuery.of(context).size.height -
            bottomRight.dy +
            (bottomRight.dy - topLeft.dy) +
            10 +
            bottomInset;
    RelativeRect relativeRect = RelativeRect.fromLTRB(
        (MediaQuery.of(context).size.width - overlaySize) / 2,
        top,
        (MediaQuery.of(context).size.width - overlaySize) / 2,
        bottom);

    overlayEntry = OverlayEntry(
      builder: (context) {
        return ReactionOverlay(
          onDismiss: () {
            hideOverlay(context);
          },
          relativeRect: relativeRect,
          overlaySize: overlaySize ?? MediaQuery.of(context).size.width * 0.3,
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
    overlayEntry!.remove();
  }
}
/*library flutter_animated_reaction;

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
    Size? iconSize,
  }) {
    final mq = MediaQueryData.fromView(View.of(context));
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final padTop = mq.viewPadding.top;
    final padBottom = mq.viewPadding.bottom;

    final box = key.currentContext!.findRenderObject() as RenderBox;
    final topLeft = box.size.topCenter(box.localToGlobal(Offset.zero));
    final bottomRight = box.size.bottomCenter(box.localToGlobal(Offset.zero));

    overlaySize ??= screenW * 0.9;

    const barH = 60.0;
    const gap = 10.0;
    const margin = 8.0;

    final placeAbove = topLeft.dy > screenH * 0.3;

    double top =
        placeAbove ? (topLeft.dy - barH - gap) : (bottomRight.dy + gap);
    final minTop = padTop + margin;
    final maxTop = screenH - padBottom - barH - margin;
    top = top.clamp(minTop, maxTop);

    final left = (screenW - overlaySize!) / 2;
    final right = left;
    final bottom = screenH - top - barH;

    final relativeRect = RelativeRect.fromLTRB(left, top, right, bottom);

    overlayEntry = OverlayEntry(
      builder: (_) => ReactionOverlay(
        onDismiss: () => hideOverlay(context),
        relativeRect: relativeRect,
        overlaySize: overlaySize!,
        reactions: reactions ?? ReactionData.facebookReactionIcon,
        onPressReact: (val) {
          hideOverlay(context);
          onReaction(val);
        },
        size: iconSize,
        backgroundColor: backgroundColor ?? Colors.white,
      ),
    );

    overlayState = Overlay.of(context);
    overlayState.insert(overlayEntry!);
  }

  void hideOverlay(BuildContext context) {
    overlayEntry?.remove();
  }
}*/
/*library flutter_animated_reaction;

import 'package:flutter/material.dart';
import 'package:flutter_animated_reaction/reaction_data.dart';

class AnimatedFlutterReaction {
  late final OverlayEntry? overlayEntry;
  late OverlayState overlayState;

  void showOverlay(
      {required BuildContext context,
      required GlobalKey key,
      List<String>? reactions,
      required Function(int) onReaction,
      Color? backgroundColor,
      double? overlaySize,
      Size? iconSize}) {
    RenderBox? box = key.currentContext!.findRenderObject() as RenderBox;
    final Offset topLeft = box.size.topCenter(box.localToGlobal(Offset.zero));
    final Offset bottomRight =
        box.size.bottomCenter(box.localToGlobal(Offset.zero));
    overlaySize ??= MediaQuery.of(context).size.width * 0.9;
    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;

    double top = topLeft.dy > MediaQuery.of(context).size.height * 0.3
        ? topLeft.dy - 70
        : bottomRight.dy;
    double bottom = topLeft.dy < MediaQuery.of(context).size.height * 0.3
        ? MediaQuery.of(context).size.height - bottomRight.dy - 60
        : MediaQuery.of(context).size.height -
            bottomRight.dy +
            (bottomRight.dy - topLeft.dy) +
            10 +
            bottomInset;
    RelativeRect relativeRect = RelativeRect.fromLTRB(
        (MediaQuery.of(context).size.width - overlaySize) / 2,
        top,
        (MediaQuery.of(context).size.width - overlaySize) / 2,
        bottom);

    overlayEntry = OverlayEntry(
      builder: (context) {
        return ReactionOverlay(
          onDismiss: () {
            hideOverlay(context);
          },
          relativeRect: relativeRect,
          overlaySize: overlaySize ?? MediaQuery.of(context).size.width * 0.3,
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
    overlayEntry!.remove();
  }
}*/
