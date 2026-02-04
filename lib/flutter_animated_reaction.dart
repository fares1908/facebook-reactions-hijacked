library flutter_animated_reaction;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animated_reaction/reaction_data.dart';
import 'package:flutter_animated_reaction/reaction_overlay.dart';

class AnimatedFlutterReaction {
  OverlayEntry? overlayEntry;
  OverlayState? overlayState;

  /// Shows the reactions overlay aligned to the widget identified by [key].
  ///
  /// ## Why this implementation (Android 15 / Edge-to-Edge fix)
  /// When `targetSdkVersion >= 35` (Android 15) and the app uses edge-to-edge
  /// (often combined with a global `SafeArea` in `MaterialApp.builder`), the
  /// system bars (status / navigation / gesture areas) can overlap the app.
  ///
  /// The original package implementation mixed coordinate systems:
  /// - reading sizes from `MediaQuery` (widget tree space),
  /// - using `localToGlobal` without an ancestor (window/global space),
  /// - and inserting into an overlay that might not share the same layout space.
  ///
  /// That mismatch causes the reaction bar to be positioned under system bars
  /// (appearing "clipped" or "eaten") on Android 15 edge-to-edge devices.
  ///
  /// ### Key changes in this version
  /// 1) **Use the Overlay inside the widget tree (SafeArea-aware)**
  ///    We call `Overlay.of(context)` (NO `rootOverlay: true`) so the overlay is
  ///    inserted into the same widget-tree coordinate space affected by SafeArea.
  ///
  /// 2) **Measure and position in the SAME coordinate space**
  ///    We derive `screenW/screenH` from `overlayBox.size` and compute the target
  ///    widget position using `localToGlobal(..., ancestor: overlayBox)`.
  ///    This ensures the target position and overlay canvas share one coordinate
  ///    system, eliminating offsets on edge-to-edge layouts.
  ///
  /// 3) **Clamp the bar within safe insets**
  ///    We use `viewPadding.top` to respect the physical status bar even when
  ///    `SafeArea(top: false)` makes `padding.top` effectively 0.
  ///    For the bottom we take the maximum of:
  ///      - `padding.bottom` (content-safe),
  ///      - `viewPadding.bottom` (system UI),
  ///      - `systemGestureInsets.bottom` (gesture navigation area)
  ///    and clamp the computed `top` so the bar never overlaps those regions.
  ///
  /// These adjustments keep the reactions bar correctly visible across
  /// Android 15 edge-to-edge devices and different navigation modes.
  void showOverlay({
    required BuildContext context,
    required GlobalKey key,
    List<String>? reactions,
    required Function(int) onReaction,
    Color? backgroundColor,
    double? overlaySize,
    Size? iconSize,
  }) {
    hideOverlay(context);

    final targetCtx = key.currentContext;
    if (targetCtx == null) return;

    final targetRO = targetCtx.findRenderObject();
    if (targetRO is! RenderBox || !targetRO.hasSize) return;

    /// Use the Overlay inside the current widget tree (SafeArea-aware).
    /// Avoid `rootOverlay: true` to prevent coordinate-space mismatch when
    /// the app is wrapped with a global SafeArea / edge-to-edge configuration.
    final overlay = Overlay.of(context);
    overlayState = overlay;

    final overlayRO = overlay.context.findRenderObject();
    if (overlayRO is! RenderBox || !overlayRO.hasSize) return;
    final overlayBox = overlayRO;

    /// `overlayBox.size` represents the actual available canvas for the overlay
    /// entry. This is more reliable than `MediaQuery.size` under edge-to-edge
    /// + SafeArea because it matches the overlay's layout constraints.
    final screenW = overlayBox.size.width;
    final screenH = overlayBox.size.height;

    /// Safe insets:
    /// - `viewPadding.top` keeps us out of the physical status bar even if
    ///   `SafeArea(top:false)` makes `padding.top == 0`.
    /// - Bottom uses the maximum of padding/viewPadding/systemGestureInsets to
    ///   stay clear of gesture navigation areas on modern Android.
    final mq = MediaQuery.of(context);
    final padTop = mq.viewPadding.top;
    final padBottom = math.max(
      math.max(mq.padding.bottom, mq.viewPadding.bottom),
      mq.systemGestureInsets.bottom,
    );

    /// Convert the target widget position into the overlay's coordinate space.
    /// This is the critical step that prevents "clipped" overlays on Android 15
    /// edge-to-edge because both the target and overlay now share one reference.
    final pos = targetRO.localToGlobal(Offset.zero, ancestor: overlayBox);
    final topCenter = targetRO.size.topCenter(pos);
    final bottomCenter = targetRO.size.bottomCenter(pos);

    // Overlay width (defaults to 90% of the overlay canvas)
    overlaySize ??= screenW * 0.9;

    // Overlay bar layout constants (must match ReactionOverlay constraints)
    const barH = 60.0;
    const gap = 10.0;
    const margin = 8.0;

    // Decide whether to place the bar above or below the target widget
    final placeAbove = topCenter.dy > screenH * 0.3;

    // Compute bar top position
    double top =
        placeAbove ? (topCenter.dy - barH - gap) : (bottomCenter.dy + gap);

    /// Clamp the overlay's vertical position so the bar never enters unsafe
    /// system UI regions (status bar / navigation bar / gesture area).
    final minTop = padTop + margin;
    final maxTop = screenH - padBottom - barH - margin;
    top = top.clamp(minTop, maxTop);

    // Center horizontally
    final left = (screenW - overlaySize) / 2;
    final bottom = screenH - top - barH;

    final relativeRect = RelativeRect.fromLTRB(left, top, left, bottom);

    overlayEntry = OverlayEntry(
      builder: (_) {
        return ReactionOverlay(
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
        );
      },
    );

    overlayState!.insert(overlayEntry!);
  }

  /// Hides the currently visible reactions overlay (if any).
  ///
  /// Keeping the `BuildContext` parameter preserves backward compatibility with
  /// the original package API, even though it is not required for removal.
  void hideOverlay(BuildContext context) {
    overlayEntry?.remove();
    overlayEntry = null;
  }
}
