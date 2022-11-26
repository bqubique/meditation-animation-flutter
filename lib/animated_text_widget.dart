import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';

class AnimatedTextWidget extends StatefulWidget {
  final VoidCallback callback;
  const AnimatedTextWidget({super.key, required this.callback});

  @override
  State<AnimatedTextWidget> createState() => _AnimatedTextWidgetState();
}

class _AnimatedTextWidgetState extends State<AnimatedTextWidget>
    with TickerProviderStateMixin {
  final _animationTime = const Duration(milliseconds: 100);

  late final AnimationController _opacityAnimationController =
      AnimationController(
    duration: _animationTime,
    vsync: this,
  );
  final Tween<double> _opacityTween = Tween(begin: 1.0, end: 0.0);
  Animation<double>? _opacityAnimation;

  int _start = 3;

  String _timeLeft = '';
  String _label = '';

  bool _isAnimationFinished = true;

  @override
  void initState() {
    _opacityAnimation = _opacityTween.animate(_opacityAnimationController)
      ..addListener(() {
        setState(() {});
      });

    super.initState();
  }

  /// Starts the timers for one complete cycle
  ///
  /// Starts breathe in, hold, breathe out, hold timers with the given labels
  void _startTimers() async {
    _isAnimationFinished = false;
    startTimerWithLabel(updateLabel: 'breathe in');
    Future.delayed(const Duration(seconds: 3), () {
      startTimerWithLabel(updateLabel: 'hold');
      Future.delayed(const Duration(seconds: 3), () {
        startTimerWithLabel(updateLabel: 'breathe out');
        Future.delayed(const Duration(seconds: 3), () {
          startTimerWithLabel(updateLabel: 'hold', isFinish: true);
          // This is 4 since we're waiting for the last tick to tick
          Future.delayed(const Duration(seconds: 4), () {
            setState(() {
              _isAnimationFinished = true;
            });
          });
        });
      });
    });
  }

  /// Starts a [Timer] and updates the time and labels
  void startTimerWithLabel({
    required String updateLabel,
    bool isFinish = false,
  }) {
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _label = updateLabel;
      });
      if (_start == 0) {
        timer.cancel();
      }
      if (_start > 0) {
        _startAnimations();
        setState(() {
          _timeLeft = _start.toString();
          _start--;
        });
      } else {
        setState(() {
          _label = isFinish ? '' : updateLabel;
          _start = 3;
          _timeLeft = isFinish ? '' : _start.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isAnimationFinished
          ? InkWell(
              child: const Icon(Icons.play_arrow_rounded, size: 100.0),
              onTap: () {
                // Delay here since Timer.periodic() delays at least a second before firing
                Future.delayed(const Duration(seconds: 1), () {
                  widget.callback();
                });
                _startTimers();
              })
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // AnimatedSwitcher for the top label (breathe in, hold, etc.)
                AnimatedSwitcher(
                  duration: _animationTime,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, -0.5),
                        end: const Offset(0.0, 0.0),
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: Text(
                    _label,
                    key: ValueKey<String>(_label),
                    style: const TextStyle(fontSize: 17, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        ...previousChildren
                            .map((e) => Opacity(
                                opacity: _opacityAnimation!.value, child: e))
                            .toList(),
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                ),
                // AnimatedSwitcher for the bottom countdown timer
                AnimatedSwitcher(
                  duration: _animationTime,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, -0.5),
                        end: const Offset(0.0, 0.0),
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: Text(
                    _timeLeft,
                    key: ValueKey<String>(_timeLeft),
                    style: const TextStyle(fontSize: 60, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      children: <Widget>[
                        ...previousChildren
                            .map((e) => Opacity(
                                opacity: _opacityAnimation!.value, child: e))
                            .toList(),
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                ),
              ],
            ),
    );
  }

  /// Checks [AnimationStatus] and starts the opacity animations correspondingly
  void _startAnimations() {
    if (_opacityAnimationController.status == AnimationStatus.completed) {
      _opacityAnimationController.reset();
      _opacityAnimationController.forward();
    } else {
      _opacityAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _opacityAnimationController.dispose();
    super.dispose();
  }
}
