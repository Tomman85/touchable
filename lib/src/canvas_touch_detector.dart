import 'dart:async';

import 'package:flutter/material.dart';
import 'package:touchable/src/types/types.dart';

///[CanvasTouchDetector] widget detects the gestures on your [CustomPaint] widget.
///
/// Wrap your [CustomPaint] widget with [CanvasTouchDetector]
/// The [builder] function passes the [BuildContext] and expects a [CustomPaint] object as its return value.
/// The [gesturesToOverride] list must contains list of gestures you want to listen to (by default contains all types of gestures).
class CanvasTouchDetector extends StatefulWidget {
  final CustomTouchPaintBuilder builder;
  final List<GestureType> gesturesToOverride;

  const CanvasTouchDetector({
    Key? key,
    required this.builder,
    this.gesturesToOverride = GestureType.values,
  }) : super(key: key);

  @override
  _CanvasTouchDetectorState createState() => _CanvasTouchDetectorState();
}

class _CanvasTouchDetectorState extends State<CanvasTouchDetector> {
  final StreamController<Gesture> touchController =
      StreamController.broadcast();
  StreamSubscription? streamSubscription;

  Future<void> addStreamListener(Function(Gesture) callBack) async {
    await streamSubscription?.cancel();
    streamSubscription = touchController.stream.listen(callBack);
  }

  @override
  Widget build(BuildContext context) {
    return TouchDetectionController(
      touchController,
      addStreamListener,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        child: Builder(
          builder: (context) {
            return widget.builder(context);
          },
        ),
        onPointerUp: (details) {
          touchController.add(
            Gesture(
              GestureType.onTapUp,
              TapUpDetails(
                globalPosition: details.localPosition, kind: details.kind,
              ),
            ),
          );
        },
        onPointerDown: (details) {
          touchController.add(
            Gesture(
              GestureType.onTapDown,
              TapDownDetails(
                globalPosition: details.localPosition,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    touchController.close();
    super.dispose();
  }
}

class TouchDetectionController extends InheritedWidget {
  final StreamController<Gesture> _controller;
  final Function addListener;

  bool get hasListener => _controller.hasListener;

  StreamController<Gesture> get controller => _controller;

  const TouchDetectionController(this._controller, this.addListener,
      {required Widget child})
      : super(child: child);

  static TouchDetectionController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TouchDetectionController>();

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
