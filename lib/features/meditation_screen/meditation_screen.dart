import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:meditation_animation_flutter/animated_text_widget.dart';
// ignore: depend_on_referenced_packages
import 'package:vector_math/vector_math.dart' as vmath;
import 'package:video_player/video_player.dart';

import '../../core/constants.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  AnimationController? _outerArcController;
  Animation<double>? _outerArcAnimation;
  final Tween<double> _outerArcTween = Tween<double>(begin: 0, end: 360);

  AnimationController? _circleRadiusController;
  Animation<double>? _circleRadiusAnimation;
  final Tween<double> _circleRadiusTween = Tween<double>(begin: 140, end: 170);

  bool _isScrubVisible = false;

  late AudioPlayer _audioPlayer;
  bool _canPlayAudio = true;

  VideoPlayerController? _videoPlayerController;
  // Video is not supported on anything but Android, iOS and Web with the official
  // [video_player] package from the Flutter team
  final bool _isVideoSupported = Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();

    _outerArcController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    _circleRadiusController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _audioPlayer = AudioPlayer();

    if (_isVideoSupported) {
      _videoPlayerController =
          VideoPlayerController.asset('assets/videos/bg_video.mp4')
            ..initialize().then((value) => setState(() {}))
            ..setVolume(0.0)
            ..setLooping(true);
    }

    _outerArcAnimation = _outerArcTween.animate(_outerArcController!)
      ..addListener(() {
        if (_outerArcAnimation!.value.toInt() == 90) {
          // NOTE: These comments have been left to verify the animation
          // plays and stops at the right time
          // dev.log('1. ${_outerArcAnimation!.value.toInt()}');
          _circleRadiusController!.stop();
          Future.delayed(const Duration(seconds: 3), () {
            // dev.log('2. ${_outerArcAnimation!.value.toInt()}');
            _circleRadiusController!.reverse();
            Future.delayed(const Duration(seconds: 3), () {
              // dev.log('3. ${_outerArcAnimation!.value.toInt()}');
              setState(() {
                _canPlayAudio = true;
              });
              _circleRadiusController!.stop();
            });
          });
        }

        setState(() {});
      });

    _circleRadiusAnimation =
        _circleRadiusTween.animate(_circleRadiusController!)
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildVideoWidget(),
        Scaffold(
          backgroundColor: _isVideoSupported
              ? Colors.transparent
              : Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: (_circleRadiusAnimation!.value * 1.2) + 90,
                  width: (_circleRadiusAnimation!.value * 1.2) + 90,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(1000)),
                    color: _isVideoSupported
                        ? Colors.transparent
                        : Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: kBoxShadow,
                  ),
                  // curve: Curves.easeInOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: _circleRadiusAnimation!.value,
                  width: _circleRadiusAnimation!.value,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(1000)),
                    color: kPrimaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white10
                            .withOpacity(_circleRadiusController!.value),
                        spreadRadius: 20,
                        blurRadius: 20.0,
                      )
                    ],
                  ),
                  child: Container(),
                ),
              ),
              AnimatedBuilder(
                animation: _outerArcAnimation!,
                builder: (context, child) {
                  return CustomPaint(
                    painter: LoadingArcPainter(
                      radian: _outerArcAnimation!.value.toInt(),
                      isCircleVisible: _isScrubVisible,
                    ),
                    child: const Center(child: SizedBox.shrink()),
                  );
                },
              ),
              Align(
                alignment: Alignment.center,
                child: AnimatedTextWidget(callback: gestureOnTapCallback),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> gestureOnTapCallback() async {
    if (_canPlayAudio) {
      await _audioPlayer.play(AssetSource('sounds/btn_sound.wav'));
      !_isVideoSupported ? null : await _videoPlayerController!.play();
    }

    if (_canPlayAudio) {
      setState(() {
        _canPlayAudio = false;
        _circleRadiusController!.forward();
        _outerArcController!.reverse();
        _outerArcController!.reset();
        _outerArcController!.stop();
        _isScrubVisible = true;
        _outerArcController!.forward();
      });
    }
  }

  @override
  void dispose() async {
    _outerArcController!.dispose();
    _circleRadiusController!.dispose();
    _isVideoSupported ? await _videoPlayerController!.dispose() : null;
    await _audioPlayer.dispose();
    super.dispose();
  }

  /// Builds the background video player
  ///
  /// Builds the background video player and adds a filter on top of the video player
  /// due to the white [BoxShadow]s not being visible enough
  Widget _buildVideoWidget() {
    return _isVideoSupported
        ? ColorFiltered(
            colorFilter: const ColorFilter.mode(
              // TODO: Change this to a "stronger" black color to see the BoxShadow's of the circles 🤠
              Colors.black54,
              BlendMode.overlay,
            ),
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoPlayerController!.value.size.width,
                  height: _videoPlayerController!.value.size.height,
                  child: VideoPlayer(_videoPlayerController!),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}

class LoadingArcPainter extends CustomPainter {
  final int radian;
  final bool isCircleVisible;
  final double strokeWidth = 4;

  LoadingArcPainter({
    required this.radian,
    required this.isCircleVisible,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Calculate the offset of the arc indicator scrub
    final scrubOffset = Offset(
      center.dx +
          100 *
              cos(-pi / 2 +
                  (radian / 57.2958)), // 1 radian is equal to 57.2958 degrees
      center.dy +
          100 *
              sin(-pi / 2 +
                  (radian / 57.2958)), // 1 radian is equal to 57.2958 degrees
    );

    canvas.drawArc(
      Rect.fromCenter(center: center, width: 200, height: 200),
      vmath.radians(-90),
      vmath.radians(360),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = Colors.white
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt,
    );

    canvas.drawArc(
      Rect.fromCenter(center: center, width: 200, height: 200),
      vmath.radians(-90),
      vmath.radians(radian.toDouble()),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = kPrimaryColor
        ..strokeWidth = strokeWidth,
    );

    if (isCircleVisible) {
      canvas.drawCircle(
        scrubOffset,
        10,
        Paint()..color = kPrimaryColor,
      );
      canvas.drawCircle(
        scrubOffset,
        5,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(LoadingArcPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(LoadingArcPainter oldDelegate) => false;
}
